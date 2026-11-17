import 'package:flutter/material.dart';

class EditableImage extends StatelessWidget {
  final ImageProvider? image;
  final Widget? placeholder;
  final double width;
  final double height;
  final VoidCallback? onEdit;
  final double borderRadius;
  final BoxFit fit;
  final Color overlayColor;
  final IconData editIcon;
  final double iconSize;

  const EditableImage({
    super.key,
    this.image,
    this.placeholder,
    this.width = 120,
    this.height = 120,
    this.onEdit,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
    this.overlayColor = Colors.black54,
    this.editIcon = Icons.edit,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.grey.shade200,
          ),
          child:
              image != null
                  ? Image(
                    image: image!,
                    fit: fit,
                    errorBuilder: (_, _, _) => _buildPlaceholder(),
                  )
                  : _buildPlaceholder(),
        ),
        if (onEdit != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: overlayColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(editIcon, size: iconSize, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child:
          placeholder ??
          const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }
}
