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

    // Adjust calories and sugar limits based on plan type
    switch (planType) {
      case PlanType.sugarControl:
        sugarLimit = 15.0; // Stricter sugar limit
        dailyCalories = dailyCalories * 0.9; // Slightly reduce calories
        break;
      case PlanType.weightLoss:
        dailyCalories = dailyCalories * 0.8; // Reduce calories by 20%
        sugarLimit = 20.0; // Moderate sugar limit
        break;
      case PlanType.muscleBuild:
        dailyCalories = dailyCalories * 1.2; // Increase calories by 20%
        sugarLimit = 30.0; // More lenient sugar limit
        break;
    }

    final rnd = Random();

    final mealTargets = {
      'breakfast': dailyCalories * 0.3,
      'lunch': dailyCalories * 0.4,
      'dinner': dailyCalories * 0.3,
    };

    List<MenuModel> selectMenus(double targetCalories, String mealType) {
      List<MenuModel> filteredMenus = _filterMenusByPlan(allMenus, planType);
      final shuffled = List<MenuModel>.from(filteredMenus)..shuffle(rnd);
      List<MenuModel> selected = [];
      double caloriesSum = 0;
      double sugarSum = 0;

      // Sort by plan priority
      shuffled.sort(
        (a, b) => _getPlanPriority(
          a,
          planType,
        ).compareTo(_getPlanPriority(b, planType)),
      );

      for (var menu in shuffled) {
        if (caloriesSum >= targetCalories) break;
        if (sugarSum + menu.sugarContent > sugarLimit) continue;

        // Additional plan-specific checks
        if (!_isMenuSuitableForPlan(menu, planType, mealType)) continue;

        selected.add(menu);
        caloriesSum += menu.calories;
        sugarSum += menu.sugarContent;
      }

      if (selected.isEmpty && shuffled.isNotEmpty) {
        selected.add(shuffled.first);
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
        // Prefer low-sugar foods
        return menus.where((menu) => menu.sugarContent <= 5.0).toList();
      case PlanType.weightLoss:
        // Prefer low-calorie foods
        return menus.where((menu) => menu.calories <= 300).toList();
      case PlanType.muscleBuild:
        // Prefer protein-rich foods (assume foods with certain keywords)
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

  static int _getPlanPriority(MenuModel menu, PlanType planType) {
    switch (planType) {
      case PlanType.sugarControl:
        // Lower sugar = higher priority (lower number = higher priority)
        return (menu.sugarContent * 10).round();
      case PlanType.weightLoss:
        // Lower calories = higher priority
        return menu.calories;
      case PlanType.muscleBuild:
        // Higher calories = higher priority (invert)
        return 1000 - menu.calories;
    }
  }

  static bool _isMenuSuitableForPlan(
    MenuModel menu,
    PlanType planType,
    String mealType,
  ) {
    switch (planType) {
      case PlanType.sugarControl:
        //sugar control
        if (mealType == 'breakfast') return menu.sugarContent <= 3.0;
        if (mealType == 'lunch') return menu.sugarContent <= 5.0;
        if (mealType == 'dinner') return menu.sugarContent <= 4.0;
        return true;
      case PlanType.weightLoss:
        // Calorie control
        if (mealType == 'breakfast') return menu.calories <= 250;
        if (mealType == 'lunch') return menu.calories <= 350;
        if (mealType == 'dinner') return menu.calories <= 300;
        return true;
      case PlanType.muscleBuild:
        //muscle building
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
        return 'เหมาะสำหรับผู้ที่ต้องการลดน้ำหนักอย่างปลอดภัย';
      case PlanType.muscleBuild:
        return 'เหมาะสำหรับผู้ที่ออกกำลังกายและต้องการเพิ่มกล้ามเนื้อ';
    }
  }
}
