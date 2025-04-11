import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/main.dart'; // Importar colores

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final VoidCallback? onArchive;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = 68; // Avatar radio (30) + padding (4) + borde (2) = 36 * 2 lados
    final double minBarHeight = avatarSize + 20; // 20 es espacio extra para que se vea bien
    
    // Calculamos la altura proporcional al nivel de interés, pero con un mínimo para contener el avatar
    // Ajustamos para que funcione con 10 niveles exactos (1-10)
    double barHeight = (contact.interestLevel / 10) * 300; // 300px es el alto total del contenedor de fondo
    barHeight = barHeight < minBarHeight ? minBarHeight : barHeight;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            
            // Contenedor de avatar e indicador de interés
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Barra vertical de fondo
                Container(
                  width: 70,
                  height: 300, // Altura fija para el fondo (base de referencia para el 100%)
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
                
                // Barra vertical de interés con avatar
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Barra de nivel de interés (siempre contiene al avatar)
                    Container(
                      width: 70,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: contact.isArchived ? [
                            Colors.grey.withAlpha(150),
                            Colors.grey,
                          ] : [
                            _getInterestLevelColor(contact.interestLevel).withAlpha(150),
                            _getInterestLevelColor(contact.interestLevel),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: _getInterestLevelColor(contact.interestLevel).withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    
                    // Avatar circular en la parte superior de la barra coloreada
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: contact.isArchived ? Colors.grey : _getInterestLevelColor(contact.interestLevel),
                          width: 2,
                        ),
                        color: AppColors.cardBg,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.cardBg,
                        backgroundImage: contact.photoPath != null
                            ? AssetImage(contact.photoPath!)
                            : null,
                        child: contact.photoPath == null
                            ? Text(
                                contact.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: contact.isArchived ? Colors.grey : _getInterestLevelColor(contact.interestLevel),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Nombre del contacto
            Text(
              contact.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: contact.isArchived ? Colors.grey[400] : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getInterestLevelColor(int level) {
    // Ajustamos para manejar 10 niveles (1-10)
    if (level >= 8) return AppColors.error;
    if (level >= 6) return AppColors.warning;
    if (level >= 4) return AppColors.success;
    return AppColors.info;
  }
}
