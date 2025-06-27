#!/bin/bash

# --- Funciones para la Checklist ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset # Más robusto que 'clear' para limpiar la pantalla
}

# Array de todas las tareas
declare -a ALL_TASKS=(
    "Verificar permisos de root"
    "Actualizar el sistema"
    "Instalar dependencias principales"
    "Definir directorio home del usuario"
    "Clonar bspwm y sxhkd"
    "Compilar e instalar bspwm"
    "Compilar e instalar sxhkd"
    "Instalar libxinerama1 y libxinerama-dev"
    "Instalar Kitty"
    "Crear directorios de configuración"
    "Copiar archivos de configuración de bspwm y sxhkd"
    "Copiar y hacer ejecutable bspwm_resize"
    "Instalar dependencias adicionales para Polybar"
    "Descargar y instalar Polybar"
    "Instalar dependencias de Picom"
    "Instalar libpcre3 y libpcre3-dev"
    "Descargar y instalar Picom"
    "Instalar Rofi"
    "Instalar bspwm desde los repositorios"
    "Copiar fuentes personalizadas"
    "Copiar configuración de Kitty"
    "Instalar Zsh"
    "Instalar complementos de Zsh"
    "Copiar configuración de Kitty a root"
    "Instalar feh"
    "Instalar ImageMagick"
    "Instalar Scrub"
    "Clonar repositorio blue-sky"
    "Crear directorio de configuración de Polybar"
    "Copiar archivos de configuración de Polybar"
    "Copiar fuentes de Polybar"
    "Actualizar caché de fuentes"
    "Crear directorio de configuración de Picom"
    "Copiar archivo de configuración de Picom"
    "Instalar Fastfetch"
    "Configurar Powerlevel10k para usuario"
    "Configurar Powerlevel10k para root"
    "Copiar .zshrc de usuario"
    "Ajustar permisos de .zshrc de usuario"
    "Copiar .zshrc de root"
    "Copiar archivos de lsd"
    "Instalar bat y lsd"
    "Actualizar .p10k.zsh de usuario"
    "Actualizar .p10k.zsh de root"
    "Crear enlace simbólico .zshrc de root"
    "Crear directorio bin en .config"
    "Copiar y dar permisos a scripts personalizados"
    "Crear directorio zsh-sudo-plugin"
    "Copiar y configurar sudo.plugin.zsh"
    "Instalar npm"
    "Instalar Flameshot"
    "Instalar i3lock"
    "Clonar e instalar i3lock-fancy"
    "Crear enlace simbólico batcat"
    "Realizar actualización final del sistema"
    "Reiniciar sesión de usuario"
)

# Array para guardar las tareas completadas
declare -a COMPLETED_TASKS=()

# Función para mostrar la lista de verificación
display_checklist() {
    clear_screen
    echo "--- Progreso de la Instalación ---"
    for task_item in "${ALL_TASKS[@]}"; do
        local found=0
        for completed_item in "${COMPLETED_TASKS[@]}"; do
            if [[ "$task_item" == "$completed_item" ]]; then
                found=1
                break
            fi
        done

        if [[ "$found" -eq 1 ]]; then
            echo "[x] $task_item"
        else
            echo "[ ] $task_item"
        fi
    done
    echo "---------------------------------"
    echo "" # Línea en blanco para separar la checklist de los mensajes del script
}

# Función para marcar una tarea como completada y actualizar la pantalla
mark_task_completed() {
    local task_name="$1"
    COMPLETED_TASKS+=("$task_name")
    display_checklist
}

# --- Inicio del Script Principal ---

display_checklist # Mostrar la checklist inicial

# Verificar si el script se ejecuta como superusuario
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi
mark_task_completed "Verificar permisos de root"

# Actualizando el sistema
echo "Actualizando el sistema..."
sudo apt update && parrot-upgrade -y
if [ $? -ne 0 ]; then
    echo "Error durante la actualización del sistema. Abortando."
    exit 1
fi
mark_task_completed "Actualizar el sistema"

# Intentar instalar dependencias
echo "Instalando dependencias..."
deps=("build-essential" "git" "vim" "libxcb-util0-dev" "libxcb-ewmh-dev" "libxcb-randr0-dev" "libxcb-icccm4-dev" "libxcb-keysyms1-dev" "libxcb-xinerama0-dev" "libasound2-dev" "libxcb-xtest0-dev" "libxcb-shape0-dev")
for dep in "${deps[@]}"; do
    if ! sudo apt install -y "$dep"; then
        echo "Advertencia: No se pudo instalar el paquete $dep. Intentando continuar..."
    fi
done
mark_task_completed "Instalar dependencias principales"

# Definir el directorio home del usuario
echo "Definir el directorio home del usuario..."
user_home=$(getent passwd $SUDO_USER | cut -d: -f6)
mark_task_completed "Definir directorio home del usuario"

# Clonar y compilar bspwm y sxhkd en el home del usuario
echo "Clonar y compilar bspwm y sxhkd en el home del usuario..."
cd "$user_home"
sudo -u $SUDO_USER git clone https://github.com/baskerville/bspwm.git
sudo -u $SUDO_USER git clone https://github.com/baskerville/sxhkd.git
mark_task_completed "Clonar bspwm y sxhkd"

# Compilar e instalar bspwm
cd "$user_home/bspwm"
sudo -u $SUDO_USER make
sudo make install
if [ $? -ne 0 ]; then
    echo "Error al instalar bspwm. Abortando."
    exit 1
fi
mark_task_completed "Compilar e instalar bspwm"

# Compilar e instalar sxhkd
cd "$user_home/sxhkd"
sudo -u $SUDO_USER make
sudo make install
if [ $? -ne 0 ]; then
    echo "Error al instalar sxhkd. Abortando."
    exit 1
fi
mark_task_completed "Compilar e instalar sxhkd"

# Instalar libxinerama1 y libxinerama-dev
sudo apt install libxinerama1 libxinerama-dev -y
if [ $? -ne 0 ]; then
    echo "Error al instalar libxinerama1 y libxinerama-dev. Abortando."
    exit 1
fi
mark_task_completed "Instalar libxinerama1 y libxinerama-dev"

# Instalar kitty
echo "Instalando kitty..."
sudo apt install kitty -y
if [ $? -ne 0 ]; then
    echo "Error al instalar kitty. Abortando."
    exit 1
fi
mark_task_completed "Instalar Kitty"

# Crear directorios de configuración
sudo -u $SUDO_USER mkdir -p "$user_home/.config/bspwm" "$user_home/.config/sxhkd" "$user_home/.config/bspwm/scripts" "$user_home/fondos"
sudo -u $SUDO_USER cp $user_home/KaliEntorno/fondos/* $user_home/fondos/
mark_task_completed "Crear directorios de configuración"

# Copiar los archivos de configuración a las carpetas de configuración
# Asegúrese de que estos pasos se ejecuten después de que el repositorio KaliEntorno se haya clonado manualmente
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/bspwm/bspwmrc" "$user_home/.config/bspwm/"
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/bspwm/setup_monitors.sh" "$user_home/.config/bspwm/"
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/"
mark_task_completed "Copiar archivos de configuración de bspwm y sxhkd"

# Copiar el script bspwm_resize al directorio de scripts
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/bspwm/scripts/bspwm_resize" "$user_home/.config/bspwm/scripts/"
# Hacer ejecutable el script bspwmrc y bspwm_resize
chmod +x "$user_home/.config/bspwm/bspwmrc"
chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize"
mark_task_completed "Copiar y hacer ejecutable bspwm_resize"

# Instalar paquetes adicionales necesarios para Polybar
sudo apt install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev -y
mark_task_completed "Instalar dependencias adicionales para Polybar"

# Descargar e instalar Polybar como usuario no privilegiado
echo "Instalando Polybar..."
cd "$user_home/Downloads"
sudo -u $SUDO_USER git clone --recursive https://github.com/polybar/polybar
cd polybar
sudo -u $SUDO_USER mkdir build
cd build
sudo -u $SUDO_USER cmake ..
sudo -u $SUDO_USER make -j$(nproc)
sudo make install
if [ $? -ne 0 ]; then
    echo "Error al instalar Polybar. Abortando."
    exit 1
fi
mark_task_completed "Descargar y instalar Polybar"

# Instalar dependencias para Picom
sudo apt install meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev -y
mark_task_completed "Instalar dependencias de Picom"

# Instalar libpcre3 y libpcre3-dev
echo "Instalando libpcre3 y libpcre3-dev..."
sudo apt install libpcre3 libpcre3-dev -y
if [ $? -ne 0 ]; then
    echo "Error al instalar libpcre3 y libpcre3-dev. Abortando."
    exit 1
fi
mark_task_completed "Instalar libpcre3 y libpcre3-dev"

# Descargar e instalar Picom como usuario no privilegiado
echo "Instalando Picom..."
cd "$user_home/Downloads"
sudo -u $SUDO_USER git clone https://github.com/ibhagwan/picom.git
cd picom
sudo -u $SUDO_USER git submodule update --init --recursive
sudo -u $SUDO_USER meson --buildtype=release . build
if [ $? -ne 0 ]; then
    echo "Error durante la configuración de meson para Picom. Abortando."
    exit 1
fi
# Compilar Picom con ninja
cd "$user_home/Downloads/picom"
sudo -u $SUDO_USER ninja -C build
if [ $? -ne 0 ]; then
    echo "Error al compilar Picom con ninja. Abortando."
    exit 1
fi
# Instalar Picom
cd "$user_home/Downloads/picom"
sudo ninja -C build install
if [ $? -ne 0 ]; then
    echo "Error al instalar Picom. Abortando."
    exit 1
fi
mark_task_completed "Descargar y instalar Picom"

# Instalar Rofi
echo "Instalando Rofi..."
sudo apt install rofi -y
if [ $? -ne 0 ]; then
    echo "Error al instalar Rofi. Abortando."
    exit 1
fi
mark_task_completed "Instalar Rofi"

# Instalar bspwm desde los repositorios
echo "Instalando bspwm desde el repositorio..."
sudo apt install bspwm -y
if [ $? -ne 0 ]; then
    echo "Error al instalar bspwm desde el repositorio. Abortando."
    exit 1
fi
mark_task_completed "Instalar bspwm desde los repositorios"

# Copiar todos los archivos de fuentes de KaliEntorno a /usr/local/share/fonts
echo "Copiando fuentes personalizadas..."
sudo cp "$user_home/KaliEntorno/fonts/"* /usr/local/share/fonts/
mark_task_completed "Copiar fuentes personalizadas"

echo "Copiando la configuración de Kitty..."
mkdir -p "$user_home/.config/kitty"
# Asegúrate de que el directorio exista
cp -r "$user_home/KaliEntorno/Config/kitty/." "$user_home/.config/kitty/"
mark_task_completed "Copiar configuración de Kitty"

# Instalar Zsh
echo "Instalando Zsh..."
sudo apt install zsh -y
if [ $? -ne 0 ]; then
    echo "Error al instalar Zsh. Abortando."
    exit 1
fi
mark_task_completed "Instalar Zsh"

# Instalar complementos de Zsh
echo "Instalando complementos de Zsh: zsh-autosuggestions y zsh-syntax-highlighting..."
sudo apt install zsh-autosuggestions zsh-syntax-highlighting -y
if [ $? -ne 0 ]; then
    echo "Error al instalar los complementos de Zsh. Abortando."
    exit 1
fi
echo "Complementos de Zsh instalados con éxito."
mark_task_completed "Instalar complementos de Zsh"

# Asegurarse de que existe el directorio de configuración de kitty para root
sudo mkdir -p /root/.config/kitty
# Copiar los archivos de configuración de kitty al directorio root
echo "Copiando configuración de kitty al directorio de root..."
sudo cp -r $user_home/.config/kitty/* /root/.config/kitty/
mark_task_completed "Copiar configuración de Kitty a root"

# Instalar feh
echo "Instalando feh..."
sudo apt install feh -y
if [ $? -ne 0 ]; then
    echo "Error al instalar feh. Abortando."
    exit 1
fi
echo "feh instalado correctamente."
mark_task_completed "Instalar feh"

# Instalar ImageMagick
echo "Instalando ImageMagick..."
sudo apt install imagemagick -y
if [ $? -ne 0 ]; then
    echo "Error al instalar ImageMagick. Abortando."
    exit 1
fi
echo "ImageMagick instalado correctamente."
mark_task_completed "Instalar ImageMagick"

# Instalar Scrub
echo "Instalando Scrub..."
sudo apt install scrub -y
if [ $? -ne 0 ]; then
    echo "Error al instalar Scrub. Abortando."
    exit 1
fi
echo "Scrub instalado correctamente."
mark_task_completed "Instalar Scrub"

# Clonar el recurso blue-sky en el directorio Downloads del usuario no privilegiado
echo "Clonando el repositorio blue-sky en el directorio Downloads..."
sudo -u $SUDO_USER git clone https://github.com/VaughnValle/blue-sky "$user_home/Downloads/blue-sky"
if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio blue-sky. Abortando."
    exit 1
fi
echo "Repositorio blue-sky clonado con éxito en la carpeta Downloads."
mark_task_completed "Clonar repositorio blue-sky"

# Crear el directorio para la configuración de Polybar
echo "Creando directorio de configuración de Polybar para el usuario no privilegiado..."
sudo -u $SUDO_USER mkdir -p "$user_home/.config/polybar"
echo "Directorio de configuración de Polybar creado."
mark_task_completed "Crear directorio de configuración de Polybar"

# Copiar los archivos de configuración de Polybar
echo "Copiando archivos de configuración de Polybar..."
sudo -u $SUDO_USER cp -a $user_home/KaliEntorno/Config/polybar/. "$user_home/.config/polybar/"
echo "Archivos de configuración de Polybar copiados."
mark_task_completed "Copiar archivos de configuración de Polybar"

echo "Copiando fuentes de Polybar al directorio del sistema..."
sudo cp -r "$user_home/KaliEntorno/Config/polybar/fonts/"* /usr/share/fonts/truetype/
mark_task_completed "Copiar fuentes de Polybar"

# Actualizar la caché de fuentes
sudo fc-cache -f -v
echo "Fuentes de Polybar copiadas al directorio de fuentes del sistema y caché actualizada."
mark_task_completed "Actualizar caché de fuentes"

# Crear la carpeta de configuración para picom como usuario no privilegiado
echo "Creando carpeta picom en .config..."
sudo -u $SUDO_USER mkdir -p "$user_home/.config/picom"
if [ $? -ne 0 ]; then
    echo "Error al crear la carpeta picom. Abortando."
    exit 1
fi
echo "Carpeta picom creada exitosamente en .config."
mark_task_completed "Crear directorio de configuración de Picom"

# Copiar el archivo de configuración de picom al directorio de configuración de picom del usuario no privilegiado
echo "Copiando archivo de configuración picom.conf a la carpeta de configuración de picom..."
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/picom/picom.conf" "$user_home/.config/picom/picom.conf"
if [ $? -ne 0 ]; then
    echo "Error al copiar el archivo picom.conf. Abortando."
    exit 1
fi
echo "Archivo picom.conf copiado exitosamente a .config/picom."
mark_task_completed "Copiar archivo de configuración de Picom"

# Instalar Fastfetch
echo "Instalando Fastfetch..."
cd "$user_home/Downloads"
sudo -u $SUDO_USER git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
sudo -u $SUDO_USER cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo -u $SUDO_USER cmake --build build --config Release --target fastfetch
sudo cp build/fastfetch /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error al instalar Fastfetch. Abortando."
    exit 1
fi
mark_task_completed "Instalar Fastfetch"

# Clonar el repositorio powerlevel10k y actualizar el archivo .zshrc para el usuario no privilegiado
echo "Configurando el tema powerlevel10k para el usuario no privilegiado..."
sudo -u $SUDO_USER git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"
sudo -u $SUDO_USER bash -c "echo 'source \$HOME/powerlevel10k/powerlevel10k.zsh-theme' >> \$HOME/.zshrc"
if [ $? -ne 0 ]; then
    echo "Error al configurar powerlevel10k. Abortando."
    exit 1
fi
echo "Tema powerlevel10k configurado correctamente."
mark_task_completed "Configurar Powerlevel10k para usuario"

# Configurar el tema powerlevel10k para el usuario root
echo "Configurando el tema powerlevel10k para el usuario root..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
echo "source /root/powerlevel10k/powerlevel10k.zsh-theme" >> /root/.zshrc
if [ $? -ne 0 ]; then
    echo "Error al configurar powerlevel10k para root. Abortando."
    exit 1
fi
echo "Tema powerlevel10k configurado correctamente para root."
mark_task_completed "Configurar Powerlevel10k para root"

# Copiar el archivo .zshrc del repositorio al directorio home del usuario no privilegiado
echo "Copiando el archivo .zshrc desde el repositorio al directorio home del usuario..."
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/zshrc/user/.zshrc" "$user_home/"
if [ $? -ne 0 ]; then
    echo "Error al copiar el archivo .zshrc. Abortando."
    exit 1
fi
echo "Archivo .zshrc copiado correctamente al directorio home del usuario no privilegiado."
mark_task_completed "Copiar .zshrc de usuario"

# Ajustar los permisos del archivo .zshrc
sudo chown $SUDO_USER:$SUDO_USER "$user_home/.zshrc"
sudo chmod 644 "$user_home/.zshrc"
echo "Permisos del archivo .zshrc ajustados correctamente."
mark_task_completed "Ajustar permisos de .zshrc de usuario"

# Copiar el archivo .zshrc de root desde el repositorio a /root
echo "Copiando el archivo .zshrc de root..."
cp "$user_home/KaliEntorno/Config/zshrc/root/.zshrc" /root/.zshrc
chown root:root /root/.zshrc
chmod 644 /root/.zshrc
echo "El archivo .zshrc de root ha sido copiado con los permisos adecuados."
mark_task_completed "Copiar .zshrc de root"

# Copiar todos los archivos de la carpeta lsd del repositorio KaliEntorno a /root (esto parece un error, debería ser Downloads o un lugar temporal)
# Asumiendo que quieres copiarlos a Downloads para luego instalarlos con dpkg
echo "Copiando archivos de lsd a $user_home/Downloads..."
sudo cp -a "$user_home/KaliEntorno/lsd/." "$user_home/Downloads/"
if [ $? -ne 0 ]; then
    echo "Error al copiar archivos de lsd. Abortando."
    exit 1
fi
echo "Archivos de lsd copiados a $user_home/Downloads."
mark_task_completed "Copiar archivos de lsd"

# Instalar paquetes .deb con dpkg como root
echo "Instalando bat y lsd..."
sudo dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb"
sudo dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb"
if [ $? -ne 0 ]; then
    echo "Error al instalar bat o lsd. Abortando."
    exit 1
fi
echo "bat y lsd instalados correctamente."
mark_task_completed "Instalar bat y lsd"

# Reemplazar el archivo .p10k.zsh con la versión personalizada del repositorio KaliEntorno
echo "Actualizando archivo .p10k.zsh para el usuario no privilegiado..."
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/Config/Power10kNormal/.p10k.zsh" "$user_home/.p10k.zsh"
if [ $? -ne 0 ]; then
    echo "Error al actualizar .p10k.zsh. Abortando."
    exit 1
fi
echo "Archivo .p10k.zsh actualizado correctamente."
mark_task_completed "Actualizar .p10k.zsh de usuario"

# Reemplazar el archivo .p10k.zsh con la versión personalizada para root
echo "Actualizando archivo .p10k.zsh para el usuario root..."
cp "$user_home/KaliEntorno/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh
if [ $? -ne 0 ]; then
    echo "Error al actualizar .p10k.zsh para root. Abortando."
    exit 1
fi
mark_task_completed "Actualizar .p10k.zsh de root"

# Crear un enlace simbólico para que root use la configuración .zshrc del usuario no privilegiado
echo "Configurando root para usar la configuración .zshrc del usuario no privilegiado..."
# NOTA: Esto sobrescribirá el .zshrc de root que acabas de copiar. Si ese es el comportamiento deseado, está bien.
# Si quieres que root tenga su propio .zshrc y no un symlink al del usuario, elimina esta línea.
sudo ln -sf "$user_home/.zshrc" /root/.zshrc
if [ $? -ne 0 ]; then
    echo "Error al crear el enlace simbólico para .zshrc de root. Abortando."
    exit 1
fi
echo "Root ahora usará la configuración .zshrc del usuario no privilegiado."
mark_task_completed "Crear enlace simbólico .zshrc de root"

# Crear una carpeta llamada bin en $user_home/.config/
echo "Creando la carpeta bin en $user_home/.config/..."
sudo -u $SUDO_USER mkdir -p "$user_home/.config/bin"
# Copiar todo lo que está en $user_home/KaliEntorno/bin a $user_home/.config/bin
echo "Copiando scripts al directorio bin de $user_home/.config/..."
sudo -u $SUDO_USER cp "$user_home/KaliEntorno/bin/"* "$user_home/.config/bin/"
# Dar permiso de ejecución a los scripts específicos en $user_home/.config/bin/
echo "Asignando permisos de ejecución a los scripts..."
sudo -u $SUDO_USER chmod +x "$user_home/.config/bin/ethernet_status.sh"
sudo -u $SUDO_USER chmod +x "$user_home/.config/bin/hackthebox_status.sh"
sudo -u $SUDO_USER chmod +x "$user_home/.config/bin/target_to_hack.sh"
echo "Scripts copiados y permisos asignados correctamente."
mark_task_completed "Crear directorio bin en .config"
mark_task_completed "Copiar y dar permisos a scripts personalizados"

# Crear la carpeta zsh-sudo-plugin en /usr/share
echo "Creando carpeta zsh-sudo-plugin en /usr/share..."
mkdir -p /usr/share/zsh-sudo-plugin
# Cambiar la propiedad de la carpeta al usuario no privilegiado y su grupo
chown $SUDO_USER:$SUDO_USER /usr/share/zsh-sudo-plugin
if [ $? -ne 0 ]; then
    echo "Error al cambiar la propiedad de la carpeta zsh-sudo-plugin. Abortando."
    exit 1
fi
echo "Carpeta zsh-sudo-plugin creada y propiedad asignada al usuario no privilegiado."
mark_task_completed "Crear directorio zsh-sudo-plugin"

# Copiar el archivo sudo.plugin.zsh a /usr/share/zsh-sudo-plugin con los permisos adecuados
echo "Copiando el archivo sudo.plugin.zsh a /usr/share/zsh-sudo-plugin..."
cp "$user_home/KaliEntorno/sudoPlugin/sudo.plugin.zsh" /usr/share/zsh-sudo-plugin/
if [ $? -ne 0 ]; then
    echo "Error al copiar el archivo sudo.plugin.zsh. Abortando."
    exit 1
fi
# Cambiar los permisos del archivo sudo.plugin.zsh a rwxr-xr-x (755)
chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh
if [ $? -ne 0 ]; then
    echo "Error al establecer permisos para sudo.plugin.zsh. Abortando."
    exit 1
fi
echo "El archivo sudo.plugin.zsh ha sido copiado y configurado con los permisos adecuados."
mark_task_completed "Copiar y configurar sudo.plugin.zsh"

# Instalar npm como root
echo "Instalando npm..."
apt install npm -y
if [ $? -ne 0 ]; then
    echo "Error al instalar npm. Abortando."
    exit 1
fi
echo "npm instalado correctamente."
mark_task_completed "Instalar npm"

# Instalar Flameshot para capturas de pantalla
echo "Instalando Flameshot..."
sudo apt install flameshot -y
if [ $? -ne 0 ]; then
    echo "Error al instalar Flameshot. Abortando."
    exit 1
fi
echo "Flameshot instalado correctamente."
mark_task_completed "Instalar Flameshot"

# Instalar i3lock para bloqueo de pantalla
echo "Instalando i3lock..."
sudo apt install i3lock -y
if [ $? -ne 0 ]; then
    echo "Error al instalar i3lock. Abortando."
    exit 1
fi
echo "i3lock instalado correctamente."
mark_task_completed "Instalar i3lock"

# Cambiar al directorio Downloads del usuario no privilegiado
cd "$user_home/Downloads"
# Clonar i3lock-fancy y compilarlo como usuario no privilegiado
echo "Clonando i3lock-fancy desde GitHub en el directorio Downloads..."
sudo -u $SUDO_USER git clone https://github.com/meskarune/i3lock-fancy.git
# Verificar si el repositorio se clonó correctamente
if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio i3lock-fancy en Downloads. Abortando."
    exit 1
fi
echo "Repositorio i3lock-fancy clonado correctamente en Downloads."
# Cambiar al directorio i3lock-fancy
cd i3lock-fancy
# Instalar i3lock-fancy como usuario no privilegiado pero utilizando sudo para obtener privilegios de root
echo "Instalando i3lock-fancy..."
sudo make install
# Verificar si i3lock-fancy se instaló correctamente
if [ $? -ne 0 ]; then
    echo "Error al instalar i3lock-fancy. Abortando."
    exit 1
fi
echo "i3lock-fancy instalado correctamente."
mark_task_completed "Clonar e instalar i3lock-fancy"

#Enlace simbolico batcat-cat
sudo ln -s /usr/bin/bat /usr/bin/batcat
mark_task_completed "Crear enlace simbólico batcat"

# Actualizando el sistema
echo "Realizando actualización final del sistema..."
sudo apt update && apt upgrade -y
if [ $? -ne 0 ]; then
    echo "Error durante la actualización final del sistema. Abortando."
    exit 1
fi
mark_task_completed "Realizar actualización final del sistema"

# Reiniciar la sesión de usuario
echo "Reiniciando la sesión de usuario..."
mark_task_completed "Reiniciar sesión de usuario"

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh


# Asegúrate de que este comando sea lo último que quieras hacer, ya que terminará la sesión actual.
kill -9 -1
