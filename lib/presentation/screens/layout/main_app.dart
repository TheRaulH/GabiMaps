import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gabimaps/presentation/screens/home/profile.dart';
import 'package:gabimaps/presentation/screens/home/red_social.dart';
import 'package:gabimaps/presentation/screens/home/saved.dart';
import 'package:gabimaps/presentation/screens/map/map_screen.dart';
import 'package:gabimaps/utils/bottom_nav_btn.dart';
import 'package:gabimaps/utils/clipper.dart';
import 'package:gabimaps/utils/size_config.dart';


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final PageController pageController = PageController();

  final List<Widget> screens =  [
    MapScreen(),
    GuardadosPage(),
    RedSocialUAGRM(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: screens,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.blockSizeHorizontal * 4.5,
        0,
        AppSizes.blockSizeHorizontal * 4.5,
        30,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        elevation: 6,
        child: Container(
          height: AppSizes.blockSizeHorizontal * 18,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: AppSizes.blockSizeHorizontal * 3,
                right: AppSizes.blockSizeHorizontal * 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BottomNavBTN(
                      icon: Icons.home,
                      index: 0,
                      currentIndex: _currentIndex,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.star,
                      index: 1,
                      currentIndex: _currentIndex,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.access_alarm_outlined,
                      index: 2,
                      currentIndex: _currentIndex,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.message_rounded,
                      index: 3,
                      currentIndex: _currentIndex,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),

                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.decelerate,
                top: 0,
                left: _animatedPositionLeftValue(_currentIndex),
                child: Column(
                  children: [
                    Container(
                      height: AppSizes.blockSizeHorizontal * 1.0,
                      width: AppSizes.blockSizeHorizontal * 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _animatedPositionLeftValue(int index) {
    switch (index) {
      case 0:
        return AppSizes.blockSizeHorizontal * 7.5;
      case 1:
        return AppSizes.blockSizeHorizontal * 28.5;
      case 2:
        return AppSizes.blockSizeHorizontal * 50;
      case 3:
        return AppSizes.blockSizeHorizontal * 71.5;
      default:
        return 0;
    }
  }

}

final List<Color> gradient = [
  Colors.blueGrey.withOpacity(0.8),
  Colors.blueGrey.withOpacity(0.5),
  Colors.transparent
];