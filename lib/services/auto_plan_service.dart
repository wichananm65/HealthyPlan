import 'dart:math';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';

class AutoPlanService {
  static Future<void> generatePlanAndSave() async {
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
    final dailyCalories = bmr * activityFactor;
    final sugarLimit = 25.0;

    final rnd = Random();

    final mealTargets = {
      'breakfast': dailyCalories * 0.3,
      'lunch': dailyCalories * 0.4,
      'dinner': dailyCalories * 0.3,
    };

    List<MenuModel> selectMenus(double targetCalories) {
      final shuffled = List<MenuModel>.from(allMenus)..shuffle(rnd);
      List<MenuModel> selected = [];
      double caloriesSum = 0;
      double sugarSum = 0;

      for (var menu in shuffled) {
        if (caloriesSum >= targetCalories) break;
        if (sugarSum + menu.sugarContent > sugarLimit) continue;
        selected.add(menu);
        caloriesSum += menu.calories;
        sugarSum += menu.sugarContent;
      }

      if (selected.isEmpty && shuffled.isNotEmpty) {
        selected.add(shuffled.first);
      }

      return selected;
    }

    final breakfast = selectMenus(mealTargets['breakfast']!);
    final lunch = selectMenus(mealTargets['lunch']!);
    final dinner = selectMenus(mealTargets['dinner']!);

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
}
