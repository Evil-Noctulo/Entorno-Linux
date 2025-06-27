#!/bin/bash

# ——————————————————————————————————————
# Aviso de duración y captura de Ctrl+C
# ——————————————————————————————————————
echo "⚠️  Este proceso puede tardar hasta 10 minutos. Por favor, no interrumpas este script."
trap '
  echo ""
  echo "❌  Atención: cancelar el script puede provocar un mal funcionamiento del entorno."
  exit 1
' SIGINT

# --- Funciones para la Checklist ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset   # Más robusto que 'clear'
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
            [[ "$task_item" == "$completed_item" ]] && { found=1; break; }
        done
        if [[ "$found" -eq 1 ]]; then
            echo "[x] $task_item"
        else
            echo "[ ] $task_item"
        fi
    done
    echo "---------------------------------"
    echo ""
}

# Función para marcar una tarea como completada y actualizar la pantalla
mark_task_completed() {
    COMPLETED_TASKS+=("$1")
    display_checklist
}

# --- Inicio del Script Principal ---

display_checklist

# Verificar permisos de root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi
mark_task_completed "Verificar permisos de root"

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && parrot-upgrade -y
mark_task_completed "Actualizar el sistema"

# Instalar dependencias principales
echo "Instalando dependencias principales..."
deps=(
    build-essential git vim libxcb-util0-dev libxcb-ewmh-dev
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev
    libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
    libxcb-shape0-dev
)
for dep in "${deps[@]}"; do
    sudo apt install -y "$dep" || echo "Advertencia: $dep no se instaló correctamente."
done
mark_task_completed "Instalar dependencias principales"

# Definir directorio home del usuario
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
mark_task_completed "Definir directorio home del usuario"

# Clonar bspwm y sxhkd
echo "Clonando bspwm y sxhkd..."
cd "$user_home"
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/bspwm.git
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/sxhkd.git
mark_task_completed "Clonar bspwm y sxhkd"

# Compilar e instalar bspwm
echo "Instalando bspwm..."
cd "$user_home/bspwm"
sudo -u "$SUDO_USER" make && sudo make install
mark_task_completed "Compilar e instalar bspwm"

# Compilar e instalar sxhkd
echo "Instalando sxhkd..."
cd "$user_home/sxhkd"
sudo -u "$SUDO_USER" make && sudo make install
mark_task_completed "Compilar e instalar sxhkd"

# Instalar libxinerama
echo "Instalando libxinerama1 y libxinerama-dev..."
sudo apt install -y libxinerama1 libxinerama-dev
mark_task_completed "Instalar libxinerama1 y libxinerama-dev"

# Instalar Kitty
echo "Instalando Kitty..."
sudo apt install -y kitty
mark_task_completed "Instalar Kitty"

# Crear directorios de configuración
echo "Creando directorios de configuración..."
sudo -u "$SUDO_USER" mkdir -p \
    "$user_home/.config/bspwm" \
    "$user_home/.config/sxhkd" \
    "$user_home/.config/bspwm/scripts" \
    "$user_home/fondos"
sudo -u "$SUDO_USER" cp -r "$user_home/Entorno-Linux/fondos/"* "$user_home/fondos/"
mark_task_completed "Crear directorios de configuración"

# Copiar configuraciones bspwm y sxhkd
echo "Copiando configuraciones de bspwm y sxhkd..."
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/bspwm/"* "$user_home/.config/bspwm/"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/"
mark_task_completed "Copiar archivos de configuración de bspwm y sxhkd"

# Copiar y hacer ejecutable bspwm_resize
echo "Instalando script bspwm_resize..."
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/bspwm/scripts/bspwm_resize" \
    "$user_home/.config/bspwm/scripts/"
chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize"
mark_task_completed "Copiar y hacer ejecutable bspwm_resize"

# Instalar dependencias Polybar
echo "Instalando dependencias para Polybar..."
sudo apt install -y \
    cmake cmake-data pkg-config python3-sphinx \
    libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libxcb-randr0-dev libxcb-composite0-dev \
    python3-xcbgen xcb-proto libxcb-image0-dev \
    libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev \
    libxcb-cursor-dev libasound2-dev libpulse-dev \
    libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev
mark_task_completed "Instalar dependencias adicionales para Polybar"

# Descargar e instalar Polybar
echo "Descargando e instalando Polybar..."
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone --recursive https://github.com/polybar/polybar
cd polybar && mkdir build && cd build
sudo -u "$SUDO_USER" cmake .. && sudo -u "$SUDO_USER" make -j"$(nproc)" && sudo make install
mark_task_completed "Descargar y instalar Polybar"

# Instalar dependencias Picom
echo "Instalando dependencias para Picom..."
sudo apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev \
    libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-render-util0-dev libxcb-render0-dev \
    libxcb-composite0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-xinerama0-dev \
    libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev \
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev
mark_task_completed "Instalar dependencias de Picom"

# Instalar libpcre3
echo "Instalando libpcre3 y libpcre3-dev..."
sudo apt install -y libpcre3 libpcre3-dev
mark_task_completed "Instalar libpcre3 y libpcre3-dev"

# Descargar e instalar Picom
echo "Descargando e instalando Picom..."
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/ibhagwan/picom.git
cd picom && sudo -u "$SUDO_USER" git submodule update --init --recursive
sudo -u "$SUDO_USER" meson --buildtype=release . build
sudo -u "$SUDO_USER" ninja -C build && sudo ninja -C build install
mark_task_completed "Descargar y instalar Picom"

# Instalar Rofi
echo "Instalando Rofi..."
sudo apt install -y rofi
mark_task_completed "Instalar Rofi"

# Instalar bspwm desde repositorio
echo "Instalando bspwm desde repositorios..."
sudo apt install -y bspwm
mark_task_completed "Instalar bspwm desde los repositorios"

# Copiar fuentes personalizadas
echo "Copiando fuentes personalizadas..."
sudo cp -r "$user_home/Entorno-Linux/fonts/"* /usr/local/share/fonts/
mark_task_completed "Copiar fuentes personalizadas"

# Copiar configuración de Kitty
echo "Copiando configuración de Kitty..."
mkdir -p "$user_home/.config/kitty"
cp -r "$user_home/Entorno-Linux/Config/kitty/." "$user_home/.config/kitty/"
mark_task_completed "Copiar configuración de Kitty"

# Instalar Zsh y plugins
echo "Instalando Zsh y complementos..."
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
mark_task_completed "Instalar Zsh"
mark_task_completed "Instalar complementos de Zsh"

# Copiar configuración de Kitty a root
echo "Copiando config de Kitty a root..."
sudo mkdir -p /root/.config/kitty
sudo cp -r "$user_home/.config/kitty/." /root/.config/kitty/
mark_task_completed "Copiar configuración de Kitty a root"

# Instalar feh
echo "Instalando feh..."
sudo apt install -y feh
mark_task_completed "Instalar feh"

# Instalar ImageMagick
echo "Instalando ImageMagick..."
sudo apt install -y imagemagick
mark_task_completed "Instalar ImageMagick"

# Instalar Scrub
echo "Instalando Scrub..."
sudo apt install -y scrub
mark_task_completed "Instalar Scrub"

# Clonar blue-sky
echo "Clonando blue-sky..."
sudo -u "$SUDO_USER" git clone https://github.com/VaughnValle/blue-sky \
    "$user_home/Downloads/blue-sky"
mark_task_completed "Clonar repositorio blue-sky"

# Crear y copiar Polybar config
echo "Creando y copiando config de Polybar..."
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/polybar"
sudo -u "$SUDO_USER" cp -a "$user_home/Entorno-Linux/Config/polybar/." \
    "$user_home/.config/polybar/"
mark_task_completed "Crear directorio de configuración de Polybar"
mark_task_completed "Copiar archivos de configuración de Polybar"

# Copiar fuentes de Polybar y actualizar caché
echo "Actualizando fuentes de Polybar..."
sudo cp -r "$user_home/Entorno-Linux/Config/polybar/fonts/"* \
    /usr/share/fonts/truetype/
sudo fc-cache -f -v
mark_task_completed "Copiar fuentes de Polybar"
mark_task_completed "Actualizar caché de fuentes"

# Crear y copiar Picom conf
echo "Configurando Picom..."
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/picom"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/picom/picom.conf" \
    "$user_home/.config/picom/"
mark_task_completed "Crear directorio de configuración de Picom"
mark_task_completed "Copiar archivo de configuración de Picom"

# Instalar Fastfetch
echo "Instalando Fastfetch..."
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
sudo -u "$SUDO_USER" cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo -u "$SUDO_USER" cmake --build build --config Release --target fastfetch
sudo cp build/fastfetch /usr/local/bin/
mark_task_completed "Instalar Fastfetch"

# Configurar Powerlevel10k
echo "Configurando Powerlevel10k..."
sudo -u "$SUDO_USER" git clone --depth=1 \
  https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"
echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' >> \
  "$user_home/.zshrc"
mark_task_completed "Configurar Powerlevel10k para usuario"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc
mark_task_completed "Configurar Powerlevel10k para root"

# Copiar .zshrc de usuario y root
echo "Copiando .zshrc de usuario y root..."
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/zshrc/user/.zshrc" \
    "$user_home/.zshrc"
chown "$SUDO_USER":"$SUDO_USER" "$user_home/.zshrc" && chmod 644 "$user_home/.zshrc"
mark_task_completed "Copiar .zshrc de usuario"
mark_task_completed "Ajustar permisos de .zshrc de usuario"

cp "$user_home/Entorno-Linux/Config/zshrc/root/.zshrc" /root/.zshrc
chown root:root /root/.zshrc && chmod 644 /root/.zshrc
mark_task_completed "Copiar .zshrc de root"

# Instalar bat y lsd (.deb)
echo "Instalando bat y lsd..."
sudo cp -a "$user_home/Entorno-Linux/lsd/." "$user_home/Downloads/"
sudo dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb"
sudo dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb"
mark_task_completed "Copiar archivos de lsd"
mark_task_completed "Instalar bat y lsd"

# Actualizar .p10k.zsh
echo "Actualizando .p10k.zsh..."
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh" \
    "$user_home/.p10k.zsh"
cp "$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh
mark_task_completed "Actualizar .p10k.zsh de usuario"
mark_task_completed "Actualizar .p10k.zsh de root"

# Crear enlace simbólico .zshrc de root
echo "Creando enlace simbólico .zshrc de root..."
sudo ln -sf "$user_home/.zshrc" /root/.zshrc
mark_task_completed "Crear enlace simbólico .zshrc de root"

# Copiar scripts personalizados a bin
echo "Instalando scripts personalizados..."
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/bin"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/bin/"* "$user_home/.config/bin/"
sudo -u "$SUDO_USER" chmod +x \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh"
mark_task_completed "Crear directorio bin en .config"
mark_task_completed "Copiar y dar permisos a scripts personalizados"

# Instalar y configurar sudo-plugin
echo "Configurando sudo-plugin..."
mkdir -p /usr/share/zsh-sudo-plugin
chown "$SUDO_USER":"$SUDO_USER" /usr/share/zsh-sudo-plugin
cp "$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh" \
    /usr/share/zsh-sudo-plugin/
chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh
mark_task_completed "Crear directorio zsh-sudo-plugin"
mark_task_completed "Copiar y configurar sudo.plugin.zsh"

# Instalar npm
echo "Instalando npm..."
sudo apt install -y npm
mark_task_completed "Instalar npm"

# Instalar Flameshot
echo "Instalando Flameshot..."
sudo apt install -y flameshot
mark_task_completed "Instalar Flameshot"

# Instalar i3lock
echo "Instalando i3lock..."
sudo apt install -y i3lock
mark_task_completed "Instalar i3lock"

# Clonar e instalar i3lock-fancy
echo "Instalando i3lock-fancy..."
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/meskarune/i3lock-fancy.git
cd i3lock-fancy
sudo make install
mark_task_completed "Clonar e instalar i3lock-fancy"

# Crear enlace simbólico batcat
echo "Creando enlace simbólico batcat..."
sudo ln -sf /usr/bin/bat /usr/bin/batcat
mark_task_completed "Crear enlace simbólico batcat"

# Actualización final del sistema
echo "Realizando actualización final del sistema..."
sudo apt update && sudo apt upgrade -y
mark_task_completed "Realizar actualización final del sistema"

#Correccion de kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh

# Reiniciar sesión de usuario (será lo último)
mark_task_completed "Reiniciar sesión de usuario"
kill -9 -1
