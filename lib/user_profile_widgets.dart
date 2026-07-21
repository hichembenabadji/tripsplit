import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'auth_ui.dart';

class TripSplitUserAvatar extends StatelessWidget {
  const TripSplitUserAvatar({
    super.key,
    this.imageBytes,
    required this.size,
    this.borderColor,
    this.borderWidth = 0,
    this.padding = 0,
    this.iconSize,
  });

  final Uint8List? imageBytes;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final double padding;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final SharedColorTokens shared = Theme.of(
      context,
    ).extension<AppColors>()!.shared;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? shared.transparent,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: imageBytes == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      shared.avatarGradientTop,
                      shared.avatarGradientBottom,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: iconSize ?? size * 0.48,
                  color: shared.white,
                ),
              )
            : Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
      ),
    );
  }
}

class TripSplitProfilePhotoField extends StatelessWidget {
  const TripSplitProfilePhotoField({
    super.key,
    required this.label,
    required this.description,
    required this.imageBytes,
    required this.onPickImage,
    this.onRemoveImage,
    this.isBusy = false,
  });

  final String label;
  final String description;
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageBytes != null;
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TripSplitFieldLabel(label: label),
        const SizedBox(height: 4),
        TripSplitInputSurface(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TripSplitUserAvatar(
                  imageBytes: imageBytes,
                  size: 64,
                  borderColor: colors.cardBorder,
                  borderWidth: 1,
                  padding: 2,
                  iconSize: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hasImage ? 'Photo ready' : 'Optional',
                        style: GoogleFonts.geist(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          color: colors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: <Widget>[
                          TextButton(
                            onPressed: isBusy ? null : onPickImage,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: colors.orangeDark,
                            ),
                            child: Text(
                              isBusy
                                  ? 'Opening library...'
                                  : hasImage
                                  ? 'Change photo'
                                  : 'Choose photo',
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.orangeDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          if (hasImage && onRemoveImage != null)
                            TextButton(
                              onPressed: isBusy ? null : onRemoveImage,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: colors.footerText,
                              ),
                              child: Text(
                                'Remove',
                                style: GoogleFonts.jetBrainsMono(
                                  color: colors.footerText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
