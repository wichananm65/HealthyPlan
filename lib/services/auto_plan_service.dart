import 'dart:math';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';

enum PlanType { sugarControl, weightLoss, muscleBuild }

class AutoPlanService {
  static Future<void> generatePlanAndSave(PlanType planType) async {
    final menuService = MenuService();
    final userService = UserService();

    await userService.loadUser();
    final allMenus = await menuService.loadAllMenus();
    if (allMenus.isEmpty) return;

    final age = userService.getAge();
    final weight = userService.getWeight();
    final height = userService.getHeight();
    final gender = userService.getGender();

    if (weight <= 0 || height <= 0) return;

    double bmr;
    if (gender == 'ชาย') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    final activityFactor = 1.3;
    double dailyCalories = bmr * activityFactor;
    double sugarLimit = 25.0;
    double minCaloriesPerDay = 0;

    switch (planType) {
      case PlanType.sugarControl:
        sugarLimit = 15.0;
        dailyCalories *= 0.95;
        break;
      case PlanType.weightLoss:
        dailyCalories *= 0.8;
        sugarLimit = 20.0;
        minCaloriesPerDay = gender == 'ชาย' ? 1500 : 1200;
        if (dailyCalories < minCaloriesPerDay)
          dailyCalories = minCaloriesPerDay;
        break;
      case PlanType.muscleBuild:
        dailyCalories *= 1.2;
        sugarLimit = 25.0;
        break;
    }

    final rnd = Random();

    final mealTargets = {
      'breakfast': dailyCalories * 0.3,
      'lunch': dailyCalories * 0.4,
      'dinner': dailyCalories * 0.3,
    };

    // track menus to avoid duplicates
    Set<String> usedMenuIds = {};
    int drinkCount = 0;

    List<MenuModel> selectMenus(double targetCalories, String mealType) {
      List<MenuModel> filteredMenus =
          _filterMenusByPlan(
            allMenus,
            planType,
          ).where((menu) => !usedMenuIds.contains(menu.id)).toList();
      filteredMenus.shuffle(rnd);

      List<MenuModel> selected = [];
      double caloriesSum = 0;
      double sugarSum = 0;
      int menuLimitPerMeal = 2;

      if (planType == PlanType.sugarControl) menuLimitPerMeal = 2;
      if (planType == PlanType.weightLoss) menuLimitPerMeal = 2;
      if (planType == PlanType.muscleBuild) menuLimitPerMeal = 3;

      for (var menu in filteredMenus) {
        if (!_isMenuSuitableForPlan(menu, planType, mealType)) continue;

        // เครื่องดื่มวันละ 1 แก้ว
        bool isDrink = menu.type.toLowerCase() == 'เครื่องดื่ม';
        if (isDrink && drinkCount >= 1) continue;
        if (selected.length >= menuLimitPerMeal) break;

        // คำนวณน้ำตาลรวม
        if (sugarSum + menu.sugarContent > sugarLimit) continue;

        selected.add(menu);
        caloriesSum += menu.calories;
        sugarSum += menu.sugarContent;
        usedMenuIds.add(menu.id);

        if (isDrink) drinkCount++;
      }

      // fallback: ถ้าไม่มีเมนูที่เลือกได้ ให้ใส่เมนูแรกที่เหมาะ
      if (selected.isEmpty && filteredMenus.isNotEmpty) {
        var fallbackMenu = filteredMenus.first;
        selected.add(fallbackMenu);
        usedMenuIds.add(fallbackMenu.id);
        if (fallbackMenu.type.toLowerCase() == 'เครื่องดื่ม') drinkCount++;
      }

      return selected;
    }

    final breakfast = selectMenus(mealTargets['breakfast']!, 'breakfast');
    final lunch = selectMenus(mealTargets['lunch']!, 'lunch');
    final dinner = selectMenus(mealTargets['dinner']!, 'dinner');

    await userService.clearAllMeals();

    for (var menu in breakfast) {
      await userService.addToMeal('breakfast', menu.id);
    }
    for (var menu in lunch) {
      await userService.addToMeal('lunch', menu.id);
    }
    for (var menu in dinner) {
      await userService.addToMeal('dinner', menu.id);
    }
  }

  static List<MenuModel> _filterMenusByPlan(
    List<MenuModel> menus,
    PlanType planType,
  ) {
    switch (planType) {
      case PlanType.sugarControl:
        return menus.where((menu) => menu.sugarContent <= 5.0).toList();
      case PlanType.weightLoss:
        return menus.where((menu) => menu.calories <= 350).toList();
      case PlanType.muscleBuild:
        return menus
            .where(
              (menu) =>
                  menu.benefit.toLowerCase().contains('โปรตีน') ||
                  menu.benefit.toLowerCase().contains('กล้ามเนื้อ') ||
                  menu.ingredient.toLowerCase().contains('ไข่') ||
                  menu.ingredient.toLowerCase().contains('เนื้อ') ||
                  menu.ingredient.toLowerCase().contains('ปลา') ||
                  menu.ingredient.toLowerCase().contains('ไก่'),
            )
            .toList();
    }
  }

  static bool _isMenuSuitableForPlan(
    MenuModel menu,
    PlanType planType,
    String mealType,
  ) {
    switch (planType) {
      case PlanType.sugarControl:
        if (mealType == 'breakfast') return menu.sugarContent <= 3.0;
        if (mealType == 'lunch') return menu.sugarContent <= 5.0;
        if (mealType == 'dinner') return menu.sugarContent <= 4.0;
        return true;
      case PlanType.weightLoss:
        if (mealType == 'breakfast') return menu.calories <= 250;
        if (mealType == 'lunch') return menu.calories <= 350;
        if (mealType == 'dinner') return menu.calories <= 300;
        return true;
      case PlanType.muscleBuild:
        if (mealType == 'breakfast') return menu.calories >= 200;
        if (mealType == 'lunch') return menu.calories >= 300;
        if (mealType == 'dinner') return menu.calories >= 250;
        return true;
    }
  }

  static String getPlanName(PlanType planType) {
    switch (planType) {
      case PlanType.sugarControl:
        return 'แผนควบคุมน้ำตาล';
      case PlanType.weightLoss:
        return 'แผนลดความอ้วน';
      case PlanType.muscleBuild:
        return 'แผนเพิ่มกล้ามเนื้อ';
    }
  }

  static String getPlanDescription(PlanType planType) {
    switch (planType) {
      case PlanType.sugarControl:
        return 'เหมาะสำหรับผู้ป่วยเบาหวานหรือต้องการควบคุมระดับน้ำตาลในเลือด';
      case PlanType.weightLoss:
        return 'เหมาะสำหรับผู้ที่ต้องการลดน้ำหนัก';
      case PlanType.muscleBuild:
        return 'เหมาะสำหรับผู้ที่ออกกำลังกายและต้องการเพิ่มกล้ามเนื้อ';
    }
  }
}
