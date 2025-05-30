import 'package:flutter/material.dart';
import '../../config/enhanced_theme.dart';
import '../animations/enhanced_animations.dart';

/// Enhanced mystical card with glassmorphism and animations
class EnhancedMysticalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPremium;
  final bool isGlowing;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool enableHover;
  final Gradient? gradient;

  const EnhancedMysticalCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.isPremium = false,
    this.isGlowing = false,
    this.glowColor,
    this.onTap,
    this.enableHover = true,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: gradient != null
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CrystalGrimoireTheme.stardustSilver.withOpacity(0.2),
                width: 1,
              ),
            )
          : isPremium
              ? CrystalGrimoireTheme.premiumCard()
              : CrystalGrimoireTheme.glassmorphismCard(
                  isGlowing: isGlowing,
                  glowColor: glowColor,
                ),
      child: child,
    );

    if (isGlowing) {
      card = PulsingGlow(
        glowColor: glowColor ?? CrystalGrimoireTheme.mysticPurple,
        child: card,
      );
    }

    if (onTap != null) {
      card = RippleEffect(
        onTap: onTap,
        rippleColor: isPremium 
            ? CrystalGrimoireTheme.celestialGold
            : CrystalGrimoireTheme.mysticPurple,
        child: card,
      );
    }

    if (enableHover) {
      card = _HoverAnimation(child: card);
    }

    return MysticalAnimations.fadeScaleIn(
      duration: CrystalGrimoireTheme.normalAnimation,
      child: card,
    );
  }
}

/// Enhanced mystical button with gradient and animations
class EnhancedMysticalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isPremium;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const EnhancedMysticalButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isPremium = false,
    this.isLoading = false,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BouncingScale(
      child: Container(
        width: width,
        height: height ?? 56,
        decoration: BoxDecoration(
          gradient: isPremium
              ? CrystalGrimoireTheme.premiumGradient
              : isPrimary
                  ? CrystalGrimoireTheme.primaryButtonGradient
                  : null,
          color: !isPrimary && !isPremium
              ? CrystalGrimoireTheme.royalPurple.withOpacity(0.3)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: !isPrimary && !isPremium
              ? Border.all(
                  color: CrystalGrimoireTheme.mysticPurple.withOpacity(0.5),
                  width: 2,
                )
              : null,
          boxShadow: [
            if (isPrimary || isPremium) ...[
              BoxShadow(
                color: isPremium
                    ? CrystalGrimoireTheme.celestialGold.withOpacity(0.3)
                    : CrystalGrimoireTheme.mysticPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (icon != null) ...[
                    Icon(
                      icon,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced loading indicator with mystical effects
class MysticalLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const MysticalLoadingIndicator({
    Key? key,
    this.message,
    this.size = 40,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingGlow(
          glowColor: color ?? CrystalGrimoireTheme.mysticPurple,
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                color ?? CrystalGrimoireTheme.amethyst,
              ),
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          ShimmerLoading(
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CrystalGrimoireTheme.stardustSilver,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Enhanced status indicator with glow effects
class StatusIndicator extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;
  final bool showGlow;

  const StatusIndicator({
    Key? key,
    required this.text,
    required this.type,
    this.icon,
    this.showGlow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData defaultIcon;

    switch (type) {
      case StatusType.success:
        color = CrystalGrimoireTheme.successGreen;
        defaultIcon = Icons.check_circle_outline;
        break;
      case StatusType.warning:
        color = CrystalGrimoireTheme.warningAmber;
        defaultIcon = Icons.warning_amber_outlined;
        break;
      case StatusType.error:
        color = CrystalGrimoireTheme.errorRed;
        defaultIcon = Icons.error_outline;
        break;
      case StatusType.info:
        color = CrystalGrimoireTheme.etherealBlue;
        defaultIcon = Icons.info_outline;
        break;
      case StatusType.premium:
        color = CrystalGrimoireTheme.celestialGold;
        defaultIcon = Icons.star_outline;
        break;
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? defaultIcon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (showGlow) {
      content = PulsingGlow(
        glowColor: color,
        glowRadius: 10,
        child: content,
      );
    }

    return MysticalAnimations.fadeScaleIn(
      delay: const Duration(milliseconds: 200),
      child: content,
    );
  }
}

enum StatusType { success, warning, error, info, premium }

/// Enhanced tier badge with animations
class TierBadge extends StatelessWidget {
  final String tier;
  final bool isActive;
  final VoidCallback? onTap;

  const TierBadge({
    Key? key,
    required this.tier,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    
    switch (tier.toLowerCase()) {
      case 'premium':
        color = CrystalGrimoireTheme.mysticPurple;
        icon = Icons.diamond_outlined;
        break;
      case 'pro':
        color = CrystalGrimoireTheme.amethyst;
        icon = Icons.auto_awesome;
        break;
      case 'founders':
        color = CrystalGrimoireTheme.celestialGold;
        icon = Icons.emoji_events_outlined;
        break;
      default:
        color = CrystalGrimoireTheme.stardustSilver;
        icon = Icons.person_outline;
    }

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: tier.toLowerCase() == 'founders'
            ? CrystalGrimoireTheme.premiumGradient
            : null,
        color: tier.toLowerCase() != 'founders'
            ? color.withOpacity(0.2)
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            tier.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (tier.toLowerCase() == 'founders' || isActive) {
      badge = PulsingGlow(
        glowColor: color,
        glowRadius: 8,
        child: badge,
      );
    }

    if (onTap != null) {
      badge = RippleEffect(
        onTap: onTap,
        rippleColor: color,
        child: badge,
      );
    }

    return badge;
  }
}

/// Hover animation widget
class _HoverAnimation extends StatefulWidget {
  final Widget child;

  const _HoverAnimation({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_HoverAnimation> createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<_HoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: CrystalGrimoireTheme.mysticPurple.withOpacity(
                      _elevationAnimation.value * 0.05,
                    ),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Mystical divider with gradient
class MysticalDivider extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  const MysticalDivider({
    Key? key,
    this.height = 1.0,
    this.margin,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          colors: [
            Colors.transparent,
            CrystalGrimoireTheme.mysticPurple,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Enhanced text with shimmer effect
class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isShimmering;

  const ShimmerText({
    Key? key,
    required this.text,
    this.style,
    this.isShimmering = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(text, style: style);
    
    if (!isShimmering) return textWidget;
    
    return ShimmerLoading(
      baseColor: CrystalGrimoireTheme.royalPurple,
      highlightColor: CrystalGrimoireTheme.amethyst,
      child: textWidget,
    );
  }
}