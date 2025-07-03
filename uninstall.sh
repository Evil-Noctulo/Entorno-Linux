#!/bin/bash

# Este script elimina los directorios y archivos creados por el script de instalación del entorno.
# ÚSALO CON PRECAUCIÓN: Los archivos eliminados NO se pueden recuperar fácilmente.

# --- Funciones de Utilidad ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset
}

# Muestra un mensaje de error y sale
handle_error() {
    local error_message="$1"
    clear_screen
    echo "¡ERROR al eliminar!"
    echo "Mensaje: $error_message"
    echo "Abortando la limpieza."
    exit 1
}

# --- Inicio del Script de Limpieza ---

clear_screen # Limpia la pantalla al inicio

echo "======================================================"
echo "          INICIO DEL PROCESO DE LIMPIEZA              "
echo "======================================================"
echo ""
echo "¡ATENCIÓN! Este script eliminará permanentemente los directorios y archivos"
echo "creados por el script de instalación del entorno. Esto incluye:"
echo "  - Repositorios clonados (bspwm, sxhkd, polybar, picom, fastfetch, i3lock-fancy, blue-sky, powerlevel10k)"
echo "  - Archivos de configuración en el directorio HOME del usuario"
echo "  - Fondos de pantalla y fuentes instaladas"
echo "  - Paquetes .deb descargados para instalación"
echo "  - Configuraciones de root relacionadas con el entorno"
echo ""
echo "¡ASEGÚRATE DE QUE QUIERES CONTINUAR! ESTA ACCIÓN ES IRREVERSIBLE."
echo ""

read -p "¿Estás seguro de que quieres continuar con la limpieza? (s/N): " -n 1 -r
echo # Mueve el cursor a una nueva línea
if [[ ! "$REPLY" =~ ^[Ss]$ ]]; then
    echo "Limpieza cancelada por el usuario."
    exit 0
fi

echo ""
echo "Iniciando la eliminación de archivos y directorios..."

# Verificar permisos de root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root para eliminar todos los archivos."
    echo "Ejecuta: sudo ./clean_environment.sh"
    exit 1
fi

# Definir directorio home del usuario no root que corrió el script original
# Usamos SUDO_USER para obtener el usuario que ejecutó 'sudo'
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
if [ -z "$USER_HOME" ]; then
    handle_error "No se pudo obtener el directorio home para el usuario original ($SUDO_USER). Por favor, ejecuta este script con 'sudo' o asegúrate de que el usuario $SUDO_USER existe."
fi

# 1. Eliminar directorios clonados en el HOME del usuario
echo "Eliminando repositorios clonados en $USER_HOME/..."
sudo rm -rf \
    "$USER_HOME/bspwm" \
    "$USER_HOME/sxhkd" || echo "Advertencia: No se pudieron eliminar bspwm o sxhkd del HOME."

# 2. Eliminar directorios clonados en el directorio Downloads del usuario
echo "Eliminando repositorios clonados en $USER_HOME/Downloads/..."
sudo rm -rf \
    "$USER_HOME/Downloads/polybar" \
    "$USER_HOME/Downloads/picom" \
    "$USER_HOME/Downloads/fastfetch" \
    "$USER_HOME/Downloads/i3lock-fancy" \
    "$USER_HOME/Downloads/blue-sky" || echo "Advertencia: No se pudieron eliminar repositorios de Downloads."

# 3. Eliminar archivos .deb descargados
echo "Eliminando archivos .deb descargados..."
sudo rm -f \
    "$USER_HOME/Downloads/bat_0.24.0_amd64.deb" \
    "$USER_HOME/Downloads/lsd_1.1.2_amd64.deb" || echo "Advertencia: No se pudieron eliminar archivos .deb."

# 4. Eliminar directorios de configuración del usuario
echo "Eliminando directorios de configuración del usuario en $USER_HOME/.config/..."
sudo rm -rf \
    "$USER_HOME/.config/bspwm" \
    "$USER_HOME/.config/sxhkd" \
    "$USER_HOME/.config/kitty" \
    "$USER_HOME/.config/polybar" \
    "$USER_HOME/.config/picom" \
    "$USER_HOME/.config/bin" || echo "Advertencia: No se pudieron eliminar directorios de configuración del usuario."

# 5. Eliminar fondos de pantalla
echo "Eliminando fondos de pantalla en $USER_HOME/fondos/..."
sudo rm -rf "$USER_HOME/fondos" || echo "Advertencia: No se pudo eliminar el directorio de fondos."

# 6. Eliminar Powerlevel10k del HOME del usuario
echo "Eliminando Powerlevel10k del HOME del usuario..."
sudo rm -rf "$USER_HOME/powerlevel10k" || echo "Advertencia: No se pudo eliminar powerlevel10k del usuario."

# 7. Eliminar archivos de configuración ocultos en el HOME del usuario
echo "Limpiando archivos de configuración ocultos en $USER_HOME/..."
# Eliminar solo si existen y no son enlaces simbólicos si se crearon así
if [ -f "$USER_HOME/.zshrc" ]; then
    # Opcional: Si el .zshrc original no era nuestro, podrías querer restaurarlo o no tocarlo.
    # Para simplificar, lo eliminamos si fue copiado por nuestro script.
    echo "Eliminando $USER_HOME/.zshrc (si fue copiado por el script)..."
    sudo rm -f "$USER_HOME/.zshrc" || echo "Advertencia: No se pudo eliminar $USER_HOME/.zshrc."
fi
if [ -f "$USER_HOME/.p10k.zsh" ]; then
    echo "Eliminando $USER_HOME/.p10k.zsh..."
    sudo rm -f "$USER_HOME/.p10k.zsh" || echo "Advertencia: No se pudo eliminar $USER_HOME/.p10k.zsh."
fi

# 8. Eliminar configuraciones de root
echo "Limpiando configuraciones de root..."
sudo rm -rf /root/.config/kitty || echo "Advertencia: No se pudo eliminar la configuración de Kitty para root."
sudo rm -rf /root/powerlevel10k || echo "Advertencia: No se pudo eliminar powerlevel10k de root."
if [ -f "/root/.zshrc" ]; then
    echo "Eliminando /root/.zshrc..."
    sudo rm -f "/root/.zshrc" || echo "Advertencia: No se pudo eliminar /root/.zshrc."
fi
if [ -f "/root/.p10k.zsh" ]; then
    echo "Eliminando /root/.p10k.zsh..."
    sudo rm -f "/root/.p10k.zsh" || echo "Advertencia: No se pudo eliminar /root/.p10k.zsh."
fi

# 9. Desinstalar paquetes instalados (opcional y complejo, requeriría una lista detallada)
# Es difícil revertir la instalación de todos los paquetes de forma segura sin afectar otras cosas.
# Por lo tanto, no se incluye una desinstalación masiva de paquetes apt.
# Si necesitas desinstalar algo específico, hazlo manualmente con `sudo apt remove <paquete>`.

# 10. Eliminar fuentes instaladas (esto puede ser complicado y afectar otras apps)
echo "Eliminando fuentes personalizadas (si se instalaron en /usr/local/share/fonts/)..."
# Esto es más delicado ya que podrías eliminar fuentes de otros programas.
# Si tus fuentes personalizadas están en un subdirectorio único, es más seguro.
# Ejemplo: sudo rm -rf /usr/local/share/fonts/my_custom_fonts_dir/
# Para este script, asumo que las copias de tu carpeta 'fonts' se mezclaron con otras fuentes.
# Si copiaste la carpeta completa 'fonts' (con un nombre específico), podrías hacer esto:
# sudo rm -rf /usr/local/share/fonts/fonts/
# Si copiaste directamente el contenido, la eliminación es más arriesgada.
# Por seguridad, solo eliminaré el directorio de las fuentes de Polybar si se sabe su nombre exacto.
# sudo rm -rf /usr/share/fonts/truetype/polybar_fonts/ # Si tuvieran un dir dedicado
echo "La eliminación de fuentes es compleja y se omite para evitar efectos no deseados."
echo "Si instalaste fuentes específicas, deberás eliminarlas manualmente."

# 11. Eliminar sudo.plugin.zsh
echo "Eliminando zsh-sudo-plugin..."
sudo rm -rf /usr/share/zsh-sudo-plugin || echo "Advertencia: No se pudo eliminar /usr/share/zsh-sudo-plugin."

echo ""
echo "======================================================"
echo "          PROCESO DE LIMPIEZA FINALIZADO              "
echo "======================================================"
echo ""
echo "La mayoría de los directorios y archivos creados por el script han sido eliminados."
echo "Algunos paquetes del sistema (como bspwm, sxhkd, polybar, etc. si se instalaron vía apt)"
echo "pueden permanecer. Deberás desinstalarlos manualmente si lo deseas."
echo ""
echo "Se recomienda **reiniciar tu sistema** para asegurar que todos los cambios surtan efecto."
echo ""

read -p "Presiona Enter para finalizar..."

exit 0
