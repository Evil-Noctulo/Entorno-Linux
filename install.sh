#!/bin/bash

# ——————————————————————————————————————————————
#    Inicializar salidas:
#    FD3 → stdout real (para la checklist)
#    stdout/stderr → /dev/null (para comandos)
# ——————————————————————————————————————————————

# abrir descriptor 3 apuntando a la salida original
exec 3>&1
# redirigir todo stdout y stderr a /dev/null
exec &>/dev/null

# ——————————————————————————————————————————————
#    Funciones de Checklist (todo su output via FD3)
# ——————————————————————————————————————————————

# Limpia la pantalla
clear_screen() {
    tput reset >&3
}

# Mostrar lista de tareas y su estado
display_checklist() {
    clear_screen
    echo "--- Progreso de la Instalación ---" >&3
    for task_item in "${ALL_TASKS[@]}"; do
        local found=0
        for completed_item in "${COMPLETED_TASKS[@]}"; do
            [[ "$task_item" == "$completed_item" ]] && { found=1; break; }
        done

        if [[ $found -eq 1 ]]; then
            echo "[x] $task_item" >&3
        else
            echo "[ ] $task_item" >&3
        fi
    done >&3
    echo "---------------------------------" >&3
    echo "" >&3
}

# Marcar tarea completada y refrescar pantalla
mark_task_completed() {
    local task_name="$1"
    COMPLETED_TASKS+=("$task_name")
    display_checklist
}

# ——————————————————————————————————————————————
#    Definición de Tareas
# ——————————————————————————————————————————————

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
    "Descargar e instalar Polybar"
    "Instalar dependencias de Picom"
    "Instalar libpcre3 y libpcre3-dev"
    "Descargar e instalar Picom"
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
    "Crear directorio de Polybar"
    "Copiar configuración de Polybar"
    "Copiar fuentes de Polybar"
    "Actualizar caché de fuentes"
    "Crear directorio de Picom"
    "Copiar config de Picom"
    "Instalar Fastfetch"
    "Configurar Powerlevel10k usuario"
    "Configurar Powerlevel10k root"
    "Copiar .zshrc usuario"
    "Ajustar permisos .zshrc usuario"
    "Copiar .zshrc root"
    "Copiar archivos de lsd"
    "Instalar bat y lsd"
    "Actualizar .p10k.zsh usuario"
    "Actualizar .p10k.zsh root"
    "Crear enlace simbólico .zshrc root"
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
    "La instalación completa puede demorar 10 minutos"
)

# arreglo para completadas
declare -a COMPLETED_TASKS=()

# ——————————————————————————————————————————————
#    Inicio del Script
# ——————————————————————————————————————————————

display_checklist    # mostrar estado inicial

# 1) Verificar root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root." >&3
    exit 1
fi
mark_task_completed "Verificar permisos de root"

# 2) Actualizar el sistema
sudo apt update && parrot-upgrade -y
mark_task_completed "Actualizar el sistema"

# 3) Instalar dependencias principales
deps=(
    build-essential git vim libxcb-util0-dev libxcb-ewmh-dev
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev
    libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
    libxcb-shape0-dev
)
for dep in "${deps[@]}"; do
    sudo apt install -y "$dep" || true
done
mark_task_completed "Instalar dependencias principales"

# 4) Definir directorio home
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
mark_task_completed "Definir directorio home del usuario"

# 5) Clonar bspwm y sxhkd
cd "$user_home"
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/bspwm.git
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/sxhkd.git
mark_task_completed "Clonar bspwm y sxhkd"

# 6) Compilar e instalar bspwm
cd bspwm
sudo -u "$SUDO_USER" make && sudo make install
mark_task_completed "Compilar e instalar bspwm"

# 7) Compilar e instalar sxhkd
cd ../sxhkd
sudo -u "$SUDO_USER" make && sudo make install
mark_task_completed "Compilar e instalar sxhkd"

# 8) Instalar libxinerama
sudo apt install -y libxinerama1 libxinerama-dev
mark_task_completed "Instalar libxinerama1 y libxinerama-dev"

# 9) Instalar Kitty
sudo apt install -y kitty
mark_task_completed "Instalar Kitty"

# 10) Crear directorios de configuración
sudo -u "$SUDO_USER" mkdir -p \
    "$user_home/.config/bspwm" \
    "$user_home/.config/sxhkd" \
    "$user_home/.config/bspwm/scripts" \
    "$user_home/fondos"
sudo -u "$SUDO_USER" cp -r "$user_home/Entorno-Linux/fondos/"* "$user_home/fondos/"
mark_task_completed "Crear directorios de configuración"

# 11) Copiar configs de bspwm y sxhkd
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/bspwm/"* "$user_home/.config/bspwm/"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/"
mark_task_completed "Copiar archivos de configuración de bspwm y sxhkd"

# 12) Copiar y hacer ejecutable bspwm_resize
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/bspwm/scripts/bspwm_resize" \
    "$user_home/.config/bspwm/scripts/"
chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize"
mark_task_completed "Copiar y hacer ejecutable bspwm_resize"

# 13) Instalar dependencias Polybar
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

# 14) Descargar e instalar Polybar
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone --recursive https://github.com/polybar/polybar
cd polybar && mkdir build && cd build
sudo -u "$SUDO_USER" cmake .. && sudo -u "$SUDO_USER" make -j"$(nproc)" && sudo make install
mark_task_completed "Descargar y instalar Polybar"

# 15) Instalar dependencias Picom
sudo apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev \
    libxcb-xfixes0-dev libxcb-render-util0-dev \
    libxcb-render0-dev libxcb-composite0-dev \
    libxcb-image0-dev libxcb-present-dev \
    libxcb-xinerama0-dev libpixman-1-dev \
    libdbus-1-dev libconfig-dev libgl1-mesa-dev \
    libpcre2-dev libevdev-dev uthash-dev \
    libev-dev libx11-xcb-dev libxcb-glx0-dev
mark_task_completed "Instalar dependencias de Picom"

# 16) Instalar libpcre3
sudo apt install -y libpcre3 libpcre3-dev
mark_task_completed "Instalar libpcre3 y libpcre3-dev"

# 17) Descargar e instalar Picom
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/ibhagwan/picom.git
cd picom && sudo -u "$SUDO_USER" git submodule update --init --recursive
sudo -u "$SUDO_USER" meson --buildtype=release . build
sudo -u "$SUDO_USER" ninja -C build && sudo ninja -C build install
mark_task_completed "Descargar y instalar Picom"

# 18) Instalar Rofi
sudo apt install -y rofi
mark_task_completed "Instalar Rofi"

# 19) Instalar bspwm desde repositorio
sudo apt install -y bspwm
mark_task_completed "Instalar bspwm desde los repositorios"

# 20) Copiar fuentes personalizadas
sudo cp -r "$user_home/Entorno-Linux/fonts/"* /usr/local/share/fonts/
mark_task_completed "Copiar fuentes personalizadas"

# 21) Copiar configuración de Kitty
mkdir -p "$user_home/.config/kitty"
cp -r "$user_home/Entorno-Linux/Config/kitty/." "$user_home/.config/kitty/"
mark_task_completed "Copiar configuración de Kitty"

# 22) Instalar Zsh y plugins
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
mark_task_completed "Instalar Zsh"
mark_task_completed "Instalar complementos de Zsh"

# 23) Copiar config de kitty a root
mkdir -p /root/.config/kitty
cp -r "$user_home/.config/kitty/." /root/.config/kitty/
mark_task_completed "Copiar configuración de Kitty a root"

# 24) Instalar feh
sudo apt install -y feh
mark_task_completed "Instalar feh"

# 25) Instalar ImageMagick
sudo apt install -y imagemagick
mark_task_completed "Instalar ImageMagick"

# 26) Instalar Scrub
sudo apt install -y scrub
mark_task_completed "Instalar Scrub"

# 27) Clonar blue-sky
sudo -u "$SUDO_USER" git clone https://github.com/VaughnValle/blue-sky \
    "$user_home/Downloads/blue-sky"
mark_task_completed "Clonar repositorio blue-sky"

# 28) Crear y copiar Polybar config
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/polybar"
sudo -u "$SUDO_USER" cp -a "$user_home/Entorno-Linux/Config/polybar/." \
    "$user_home/.config/polybar/"
mark_task_completed "Crear directorio de Polybar"
mark_task_completed "Copiar configuración de Polybar"

# 29) Copiar fuentes de Polybar y actualizar caché
sudo cp -r "$user_home/Entorno-Linux/Config/polybar/fonts/"* \
    /usr/share/fonts/truetype/
sudo fc-cache -f -v
mark_task_completed "Copiar fuentes de Polybar"
mark_task_completed "Actualizar caché de fuentes"

# 30) Crear y copiar Picom conf
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/picom"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/picom/picom.conf" \
    "$user_home/.config/picom/"
mark_task_completed "Crear directorio de Picom"
mark_task_completed "Copiar config de Picom"

# 31) Instalar Fastfetch
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
sudo -u "$SUDO_USER" cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo -u "$SUDO_USER" cmake --build build --config Release --target fastfetch
sudo cp build/fastfetch /usr/local/bin/
mark_task_completed "Instalar Fastfetch"

# 32) Configurar Powerlevel10k
sudo -u "$SUDO_USER" git clone --depth=1 \
  https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"
echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' >> \
  "$user_home/.zshrc"
mark_task_completed "Configurar Powerlevel10k usuario"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc
mark_task_completed "Configurar Powerlevel10k root"

# 33) Copiar y ajustar .zshrc de usuario y root
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/zshrc/user/.zshrc" \
    "$user_home/.zshrc"
chown "$SUDO_USER":"$SUDO_USER" "$user_home/.zshrc"
chmod 644 "$user_home/.zshrc"
mark_task_completed "Copiar .zshrc usuario"
mark_task_completed "Ajustar permisos .zshrc usuario"

cp "$user_home/Entorno-Linux/Config/zshrc/root/.zshrc" /root/.zshrc
chown root:root /root/.zshrc && chmod 644 /root/.zshrc
mark_task_completed "Copiar .zshrc root"

# 34) Copiar e instalar bat y lsd (.deb)
sudo cp -a "$user_home/Entorno-Linux/lsd/." "$user_home/Downloads/"
sudo dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb"
sudo dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb"
mark_task_completed "Copiar archivos de lsd"
mark_task_completed "Instalar bat y lsd"

# 35) Actualizar .p10k.zsh
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh" \
    "$user_home/.p10k.zsh"
cp "$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh
mark_task_completed "Actualizar .p10k.zsh usuario"
mark_task_completed "Actualizar .p10k.zsh root"

# 36) Link de .zshrc de root → user
sudo ln -sf "$user_home/.zshrc" /root/.zshrc
mark_task_completed "Crear enlace simbólico .zshrc root"

# 37) Copiar scripts a bin y dar permisos
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/bin"
sudo -u "$SUDO_USER" cp "$user_home/Entorno-Linux/bin/"* \
    "$user_home/.config/bin/"
sudo -u "$SUDO_USER" chmod +x \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh"
mark_task_completed "Crear directorio bin en .config"
mark_task_completed "Copiar y dar permisos a scripts personalizados"

# 38) Instalar sudo-plugin
mkdir -p /usr/share/zsh-sudo-plugin
chown "$SUDO_USER":"$SUDO_USER" /usr/share/zsh-sudo-plugin
cp "$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh" \
    /usr/share/zsh-sudo-plugin/
chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh
mark_task_completed "Crear directorio zsh-sudo-plugin"
mark_task_completed "Copiar y configurar sudo.plugin.zsh"

# 39) Instalar npm
sudo apt install -y npm
mark_task_completed "Instalar npm"

# 40) Instalar Flameshot
sudo apt install -y flameshot
mark_task_completed "Instalar Flameshot"

# 41) Instalar i3lock
sudo apt install -y i3lock
mark_task_completed "Instalar i3lock"

# 42) Clonar e instalar i3lock-fancy
cd "$user_home/Downloads"
sudo -u "$SUDO_USER" git clone https://github.com/meskarune/i3lock-fancy.git
cd i3lock-fancy
sudo make install
mark_task_completed "Clonar e instalar i3lock-fancy"

# 43) Crear enlace batcat
sudo ln -sf /usr/bin/bat /usr/bin/batcat
mark_task_completed "Crear enlace simbólico batcat"

# 44) Actualización final
sudo apt update && sudo apt upgrade -y
mark_task_completed "Realizar actualización final del sistema"

#Correccion de kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh


# 45) Reiniciar sesión (¡será lo último que haga!)
mark_task_completed "Reiniciar sesión de usuario"
kill -9 -1
