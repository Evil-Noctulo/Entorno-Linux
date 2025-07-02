#!/bin/bash

# --- Funciones para la Checklist ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset # Más robusto que 'clear'
}

# Array de todas las tareas
declare -a ALL_TASKS=(
    "Verificar permisos de root"
    "Mostrar aviso inicial"
    "Actualizar el sistema"
    "Instalar dependencias principales"
    "Definir directorio home del usuario"
    "Clonar bspwm y sxhkd"
    "Compilar e instalar bspwm"
    "Compilar e instalar sxhkd"
    "Instalar libxinerama1 y libxinerama-dev"
    "Instalar Kitty"
    "Corregir instalación de Kitty" # ¡NUEVA TAREA AÑADIDA AQUÍ!
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
        done # <-- ¡CORREGIDO! Antes había un 'F'
        
        if [[ "$found" -eq 1 ]]; then
            echo "[x] $task_item"
        else
            echo "[ ] $task_item"
        fi
    done
    echo "---------------------------------"
    echo "" # Deja una línea en blanco al final de la checklist
}

# Función para marcar una tarea como completada y actualizar la pantalla
mark_task_completed() {
    COMPLETED_TASKS+=("$1")
    display_checklist
}

# Función para manejar errores y salir (si es necesario)
handle_error() {
    local task_name="$1"
    local error_message="$2"
    clear_screen
    echo "¡ERROR!"
    echo "Falló la tarea: $task_name"
    echo "Mensaje: $error_message"
    echo "Abortando el script."
    exit 1
}

# --- Inicio del Script Principal ---

# Captura de Ctrl+C
trap '
    clear_screen
    echo ""
    echo "❌ Atención: El script ha sido cancelado."
    echo "La cancelación de la instalación en medio del proceso podría dejar"
    echo "tu entorno en un estado inestable o incompleto, requiriendo"
    echo "una intervención manual para corregirlo."
    echo "Saliendo..."
    exit 1
' SIGINT

display_checklist # Muestra la checklist inicial vacía

# Verificar permisos de root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi
mark_task_completed "Verificar permisos de root"

# Mensaje de información para el usuario y espera
clear_screen # Limpia antes de mostrar el mensaje
echo "======================================================"
echo "          INICIO DE LA INSTALACIÓN DEL ENTORNO        "
echo "======================================================"
echo ""
echo "¡Atención!"
echo "Este proceso de instalación puede tardar aproximadamente 10 minutos."
echo "Por favor, no cierres la terminal ni interrumpas el script (Ctrl+C)."
echo "La cancelación de la instalación en medio del proceso podría dejar"
echo "tu entorno en un estado inestable o incompleto, requiriendo"
echo "una intervención manual para corregirlo."
echo ""
echo "Presiona Enter para continuar con la instalación..."
read -r # Espera a que el usuario presione Enter

mark_task_completed "Mostrar aviso inicial" # Marca la tarea de aviso como completada

# Actualizar el sistema
log_action="Actualizar el sistema"
# Intentar parrot-upgrade, si falla, usar apt upgrade
if ! parrot-upgrade -y > /dev/null 2>&1; then # AÑADIDO: Redirigir la salida aquí también
    echo "Advertencia: 'parrot-upgrade' falló o no está disponible. Intentando 'apt upgrade'." >&2
    if ! sudo apt upgrade -y > /dev/null 2>&1; then
        handle_error "$log_action" "Error durante la actualización del sistema con 'apt upgrade'."
    fi
fi 
sudo apt autoremove -y > /dev/null 2>&1 # Limpia paquetes viejos
mark_task_completed "$log_action"

# Instalar dependencias principales
log_action="Instalar dependencias principales"
deps=(
    build-essential git vim libxcb-util0-dev libxcb-ewmh-dev
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev
    libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
    libxcb-shape0-dev libxcb-xinput-dev # Añadida libxcb-xinput-dev
)
for dep in "${deps[@]}"; do
    if ! sudo apt install -y "$dep" > /dev/null 2>&1; then
        echo "Advertencia: La dependencia '$dep' no se instaló correctamente. Esto podría causar problemas más adelante." >&2
    fi
done
mark_task_completed "$log_action"

# Definir directorio home del usuario
log_action="Definir directorio home del usuario"
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
if [ -z "$user_home" ]; then
    handle_error "$log_action" "No se pudo obtener el directorio home para el usuario $SUDO_USER."
fi
mark_task_completed "$log_action"

# Clonar bspwm y sxhkd
log_action="Clonar bspwm y sxhkd"
cd "$user_home" || handle_error "$log_action" "No se pudo cambiar al directorio home del usuario: $user_home."
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/bspwm.git > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar bspwm."
fi
sudo -u "$SUDO_USER" git clone https://github.com/baskerville/sxhkd.git > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar sxhkd."
fi
mark_task_completed "$log_action"

# Compilar e instalar bspwm
log_action="Compilar e instalar bspwm"
cd "$user_home/bspwm" || handle_error "$log_action" "No se pudo cambiar al directorio de bspwm."
sudo -u "$SUDO_USER" make > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al compilar bspwm. Revisa los logs para dependencias faltantes."
fi
sudo make install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar bspwm. Revisa los logs."
fi
mark_task_completed "$log_action"

# Compilar e instalar sxhkd
log_action="Compilar e instalar sxhkd"
cd "$user_home/sxhkd" || handle_error "$log_action" "No se pudo cambiar al directorio de sxhkd."
sudo -u "$SUDO_USER" make > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al compilar sxhkd. Revisa los logs para dependencias faltantes."
fi
sudo make install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar sxhkd. Revisa los logs."
fi
mark_task_completed "$log_action"

# Instalar libxinerama
log_action="Instalar libxinerama1 y libxinerama-dev"
sudo apt install -y libxinerama1 libxinerama-dev > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar libxinerama. Asegúrate de que los repositorios estén correctos."
fi
mark_task_completed "$log_action"

# Instalar Kitty
log_action="Instalar Kitty"
sudo apt install -y kitty > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Kitty. Asegúrate de que los repositorios estén correctos."
fi
mark_task_completed "$log_action"

# --- CORRECCIÓN DE KITTY ---
log_action="Corregir instalación de Kitty"
sudo rm -f /usr/bin/kitty > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Advertencia: No se pudo eliminar el binario existente de Kitty en /usr/bin/kitty (podría no existir, lo cual es normal). Continuando..." >&2
fi
sudo tee /usr/local/bin/kitty > /dev/null << EOF
#!/usr/bin/env bash
exec /home/sinh/.local/kitty.app/bin/kitty "\$@"
EOF
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear el script wrapper para Kitty en /usr/local/bin."
fi
sudo chmod +x /usr/local/bin/kitty > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al dar permisos de ejecución al script wrapper de Kitty."
fi
mark_task_completed "$log_action"
# --- FIN DE LA CORRECCIÓN DE KITTY ---

# Crear directorios de configuración
log_action="Crear directorios de configuración"
sudo -u "$SUDO_USER" mkdir -p \
    "$user_home/.config/bspwm" \
    "$user_home/.config/sxhkd" \
    "$user_home/.config/bspwm/scripts" \
    "$user_home/fondos" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorios de configuración para el usuario."
fi
sudo cp -r "$user_home/Entorno-Linux/fondos/"* "$user_home/fondos/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar fondos. Asegúrate de que '$user_home/Entorno-Linux/fondos/' exista y tenga permisos."
fi
mark_task_completed "$log_action"

# Copiar los archivos de configuración a las carpetas de configuración
log_action="Copiar archivos de configuración de bspwm y sxhkd"
sudo cp "$user_home/Entorno-Linux/Config/bspwm/bspwmrc" "$user_home/.config/bspwm/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar bspwmrc. Asegúrate de que '$user_home/Entorno-Linux/Config/bspwm/bspwmrc' exista."
fi
sudo cp "$user_home/Entorno-Linux/Config/bspwm/setup_monitors.sh" "$user_home/.config/bspwm/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar setup_monitors.sh. Asegúrate de que exista."
fi
sudo cp "$user_home/Entorno-Linux/Config/bspwm/setup_monitorsPortatil.sh" "$user_home/.config/bspwm/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar setup_monitorsPortatil.sh. Asegúrate de que exista."
fi
sudo cp "$user_home/Entorno-Linux/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar sxhkdrc. Asegúrate de que exista."
fi
mark_task_completed "$log_action"

# Copiar el script bspwm_resize al directorio de scripts
log_action="Copiar y hacer ejecutable bspwm_resize"
sudo cp "$user_home/Entorno-Linux/Config/bspwm/scripts/bspwm_resize" "$user_home/.config/bspwm/scripts/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar bspwm_resize. Asegúrate de que exista."
fi
# Hacer ejecutable el script bspwmrc y bspwm_resize
chmod +x "$user_home/.config/bspwm/bspwmrc" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al dar permisos de ejecución a bspwmrc."
fi
chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al dar permisos de ejecución a bspwm_resize."
fi
mark_task_completed "$log_action"

# Instalar paquetes adicionales necesarios para Polybar
log_action="Instalar dependencias adicionales para Polybar"
sudo apt install -y \
    cmake cmake-data pkg-config python3-sphinx \
    libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libxcb-randr0-dev libxcb-composite0-dev \
    python3-xcbgen xcb-proto libxcb-image0-dev \
    libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev \
    libxcb-cursor-dev libasound2-dev libpulse-dev \
    libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev \
    libxcb-xinput-dev 
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar algunas dependencias de Polybar. Revisa la conexión o los repositorios."
fi
mark_task_completed "$log_action"

# Descargar e instalar Polybar como usuario no privilegiado
log_action="Descargar y instalar Polybar"
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
sudo -u "$SUDO_USER" git clone --recursive https://github.com/polybar/polybar
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar Polybar. Revisa tu conexión a internet o los permisos."
fi
cd polybar && sudo -u "$SUDO_USER" mkdir build && cd build || handle_error "$log_action" "No se pudo preparar el directorio de Polybar."

# IMPORTANTE: Aquí la salida de cmake NO se redirige para ver errores específicos.

sudo -u "$SUDO_USER" cmake ..
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al ejecutar cmake para Polybar. Revisa la salida de cmake para dependencias faltantes."
fi
sudo -u "$SUDO_USER" make -j"$(nproc)" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al compilar Polybar. Revisa los logs de compilación."
fi
sudo make install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Polybar."
fi
mark_task_completed "$log_action"

# Instalar dependencias Picom
log_action="Instalar dependencias de Picom"
sudo apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev \
    libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-render-util0-dev libxcb-render0-dev \
    libxcb-composite0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-xinerama0-dev \
    libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev \
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar dependencias de Picom. Revisa la conexión o los repositorios."
fi
mark_task_completed "$log_action"

# Instalar libpcre3
log_action="Instalar libpcre3 y libpcre3-dev"
sudo apt install -y libpcre3 libpcre3-dev > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar libpcre3. Asegúrate de que los repositorios estén correctos."
fi
mark_task_completed "$log_action"

# Descargar e instalar Picom como usuario no privilegiado
log_action="Descargar y instalar Picom"
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
sudo -u "$SUDO_USER" git clone https://github.com/ibhagwan/picom.git
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar Picom. Revisa tu conexión a internet o los permisos."
fi
cd picom && sudo -u "$SUDO_USER" git submodule update --init --recursive > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al actualizar submódulos de Picom. Revisa la conexión."
fi
# IMPORTANTE: Aquí la salida de meson NO se redirige para ver errores específicos.
sudo -u "$SUDO_USER" meson --buildtype=release . build
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al configurar meson para Picom. Revisa la salida para dependencias faltantes."
fi
sudo -u "$SUDO_USER" ninja -C build > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al compilar Picom. Revisa los logs de compilación."
fi
sudo ninja -C build install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Picom."
fi
mark_task_completed "$log_action"

# Instalar Rofi
log_action="Instalar Rofi"
sudo apt install -y rofi > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Rofi."
fi
mark_task_completed "$log_action"

# Instalar bspwm desde repositorio (Esto puede ser redundante si ya se compiló, pero se mantiene si es necesario para dependencias o versión de repo)
log_action="Instalar bspwm desde los repositorios"
sudo apt install -y bspwm > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar bspwm desde el repositorio."
fi
mark_task_completed "$log_action"

# Copiar fuentes personalizadas
log_action="Copiar fuentes personalizadas"
sudo cp -r "$user_home/Entorno-Linux/fonts/"* /usr/local/share/fonts/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar fuentes. Asegúrate de que '$user_home/Entorno-Linux/fonts/' exista y tenga contenido."
fi
mark_task_completed "$log_action"

# Copiar configuración de Kitty
log_action="Copiar configuración de Kitty"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/kitty" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorio de config de Kitty para el usuario."
fi
sudo cp -r "$user_home/Entorno-Linux/Config/kitty/." "$user_home/.config/kitty/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar config de Kitty para el usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/kitty/' exista."
fi
mark_task_completed "$log_action"

# Instalar Zsh y plugins
log_action="Instalar Zsh"
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Zsh o sus complementos. Revisa los repositorios."
fi
mark_task_completed "$log_action"
mark_task_completed "Instalar complementos de Zsh" # Depende de la anterior

# Copiar configuración de Kitty a root
log_action="Copiar configuración de Kitty a root"
sudo mkdir -p /root/.config/kitty > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorio de config de Kitty para root."
fi
sudo cp -r "$user_home/.config/kitty/." /root/.config/kitty/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar config de Kitty para root."
fi
mark_task_completed "$log_action"

# Instalar feh
log_action="Instalar feh"
sudo apt install -y feh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar feh."
fi
mark_task_completed "$log_action"

# Instalar ImageMagick
log_action="Instalar ImageMagick"
sudo apt install -y imagemagick > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar ImageMagick."
fi
mark_task_completed "$log_action"

# Instalar Scrub
log_action="Instalar Scrub"
sudo apt install -y scrub > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Scrub."
fi
mark_task_completed "$log_action"

# Clonar blue-sky
log_action="Clonar repositorio blue-sky"
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
sudo -u "$SUDO_USER" git clone https://github.com/VaughnValle/blue-sky \
    "$user_home/Downloads/blue-sky" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar blue-sky. Revisa tu conexión a internet o los permisos."
fi
mark_task_completed "$log_action"

# Crear y copiar Polybar config
log_action="Crear directorio de configuración de Polybar"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/polybar" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorio de Polybar para el usuario."
fi
mark_task_completed "$log_action"

log_action="Copiar archivos de configuración de Polybar"
sudo cp -a "$user_home/Entorno-Linux/Config/polybar/." \
    "$user_home/.config/polybar/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar config de Polybar. Asegúrate de que '$user_home/Entorno-Linux/Config/polybar/' exista."
fi
mark_task_completed "$log_action"

# Copiar fuentes de Polybar y actualizar caché
log_action="Copiar fuentes de Polybar"
sudo cp -r "$user_home/Entorno-Linux/Config/polybar/fonts/"* \
    /usr/share/fonts/truetype/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar fuentes de Polybar. Asegúrate de que '$user_home/Entorno-Linux/Config/polybar/fonts/' exista."
fi
mark_task_completed "$log_action"

log_action="Actualizar caché de fuentes"
sudo fc-cache -f -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al actualizar caché de fuentes."
fi
mark_task_completed "$log_action"

# Crear y copiar Picom conf
log_action="Crear directorio de configuración de Picom"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/picom" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorio de Picom para el usuario."
fi
mark_task_completed "$log_action"

log_action="Copiar archivo de configuración de Picom"
sudo cp "$user_home/Entorno-Linux/Config/picom/picom.conf" \
    "$user_home/.config/picom/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar config de Picom. Asegúrate de que '$user_home/Entorno-Linux/Config/picom/picom.conf' exista."
fi
mark_task_completed "$log_action"

# Instalar Fastfetch
log_action="Instalar Fastfetch"
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
sudo -u "$SUDO_USER" git clone https://github.com/fastfetch-cli/fastfetch.git
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar Fastfetch. Revisa tu conexión a internet o los permisos."
fi
cd fastfetch || handle_error "$log_action" "No se pudo cambiar al directorio de Fastfetch."
sudo -u "$SUDO_USER" cmake -B build -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al configurar cmake para Fastfetch. Revisa la salida de cmake."
fi
sudo -u "$SUDO_USER" cmake --build build --config Release --target fastfetch > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al compilar Fastfetch. Revisa los logs de compilación."
fi
sudo cp build/fastfetch /usr/local/bin/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Fastfetch en /usr/local/bin."
fi
mark_task_completed "$log_action"

# Configurar Powerlevel10k
log_action="Configurar Powerlevel10k para usuario"
sudo -u "$SUDO_USER" git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar powerlevel10k para el usuario."
fi
echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' >> \
    "$user_home/.zshrc" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al configurar .zshrc para powerlevel10k del usuario."
fi
mark_task_completed "$log_action"

log_action="Configurar Powerlevel10k para root"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar powerlevel10k para root."
fi
echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al configurar .zshrc para powerlevel10k de root."
fi
mark_task_completed "$log_action"

# Copiar .zshrc de usuario y root
log_action="Copiar .zshrc de usuario"
sudo cp "$user_home/Entorno-Linux/Config/zshrc/user/.zshrc" \
    "$user_home/.zshrc" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar .zshrc de usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/zshrc/user/.zshrc' exista."
fi
mark_task_completed "$log_action"

log_action="Ajustar permisos de .zshrc de usuario"
chown "$SUDO_USER":"$SUDO_USER" "$user_home/.zshrc" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al cambiar propietario de .zshrc de usuario."
fi
chmod 644 "$user_home/.zshrc" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al cambiar permisos de .zshrc de usuario."
fi
mark_task_completed "$log_action"

log_action="Copiar .zshrc de root"
cp "$user_home/Entorno-Linux/Config/zshrc/root/.zshrc" /root/.zshrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar .zshrc de root. Asegúrate de que '$user_home/Entorno-Linux/Config/zshrc/root/.zshrc' exista."
fi
chown root:root /root/.zshrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al cambiar propietario de .zshrc de root."
fi
chmod 644 /root/.zshrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al cambiar permisos de .zshrc de root."
fi
mark_task_completed "$log_action"

# Instalar bat y lsd (.deb)
log_action="Copiar archivos de lsd"
sudo cp -a "$user_home/Entorno-Linux/lsd/." "$user_home/Downloads/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar archivos de lsd a Downloads. Asegúrate de que '$user_home/Entorno-Linux/lsd/' exista."
fi
mark_task_completed "$log_action"

log_action="Instalar bat y lsd"
sudo dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar bat (dpkg). Asegúrate de que el archivo .deb exista y sea válido."
fi
sudo dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar lsd (dpkg). Asegúrate de que el archivo .deb exista y sea válido."
fi
mark_task_completed "$log_action"

# Actualizar .p10k.zsh
log_action="Actualizar .p10k.zsh de usuario"
sudo cp "$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh" \
    "$user_home/.p10k.zsh" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al actualizar .p10k.zsh de usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh' exista."
fi
mark_task_completed "$log_action"

log_action="Actualizar .p10k.zsh de root"
cp "$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al actualizar .p10k.zsh de root. Asegúrate de que '$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh' exista."
fi
mark_task_completed "$log_action"

# Crear enlace simbólico .zshrc de root
log_action="Crear enlace simbólico .zshrc de root"
# Este enlace podría causar problemas si .zshrc del usuario es borrado.
# Es preferible copiar el archivo a /root/.zshrc y gestionarlo por separado.
# No se recomienda un enlace simbólico entre el home de un usuario y /root.
# Si el objetivo es que el .zshrc de root sea idéntico, es mejor copiarlo.
# Recomiendo que el .zshrc de root sea una copia independiente para evitar dependencias.
# Dejo el comando, pero con la advertencia.
sudo ln -sf "$user_home/.zshrc" /root/.zshrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear enlace simbólico .zshrc de root."
fi
mark_task_completed "$log_action"

# Copiar scripts personalizados a bin
log_action="Crear directorio bin en .config"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/bin" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear el directorio bin en .config."
fi
mark_task_completed "$log_action"

log_action="Copiar y dar permisos a scripts personalizados"
# La línea de cp debería haber cambiado ya a 'sudo cp'
sudo cp "$user_home/Entorno-Linux/bin/"* "$user_home/.config/bin/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar scripts personalizados. Asegúrate de que '$user_home/Entorno-Linux/bin/' exista y tenga contenido."
fi

# AHORA EL CAMBIO CRÍTICO: Elimina '-u "$SUDO_USER"' de chmod
sudo chmod +x \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al dar permisos de ejecución a scripts personalizados."
fi

# Y asegúrate de que esta sección para cambiar la propiedad esté presente y correcta
sudo chown "$SUDO_USER":"$SUDO_USER" \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Advertencia: No se pudo cambiar la propiedad de los scripts en $user_home/.config/bin." >&2
fi

mark_task_completed "$log_action"

# Instalar y configurar sudo-plugin
log_action="Crear directorio zsh-sudo-plugin"
sudo mkdir -p /usr/share/zsh-sudo-plugin > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear directorio zsh-sudo-plugin."
fi
# La línea de chown a "$SUDO_USER" no debería ser necesaria para /usr/share/, root es el propietario.
# Si se hizo, podría causar problemas de permisos. Lo quito por seguridad.
# sudo chown "$SUDO_USER":"$SUDO_USER" /usr/share/zsh-sudo-plugin > /dev/null 2>&1
# if [ $? -ne 0 ]; then
#       handle_error "$log_action" "Error al cambiar propietario de zsh-sudo-plugin."
# fi
mark_task_completed "$log_action"

log_action="Copiar y configurar sudo.plugin.zsh"
sudo cp "$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh" \
    /usr/share/zsh-sudo-plugin/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al copiar sudo.plugin.zsh. Asegúrate de que '$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh' exista."
fi
sudo chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al dar permisos de ejecución a sudo.plugin.zsh."
fi
mark_task_completed "$log_action"

# Instalar npm
log_action="Instalar npm"
sudo apt install -y npm > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar npm."
fi
mark_task_completed "$log_action"

# Instalar Flameshot
log_action="Instalar Flameshot"
sudo apt install -y flameshot > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar Flameshot."
fi
mark_task_completed "$log_action"

# Instalar i3lock
log_action="Instalar i3lock"
sudo apt install -y i3lock > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar i3lock."
fi
mark_task_completed "$log_action"

# Clonar e instalar i3lock-fancy
log_action="Clonar e instalar i3lock-fancy"
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
sudo -u "$SUDO_USER" git clone https://github.com/meskarune/i3lock-fancy.git > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al clonar i3lock-fancy. Revisa tu conexión a internet o los permisos."
fi
cd i3lock-fancy || handle_error "$log_action" "No se pudo cambiar al directorio de i3lock-fancy."
sudo make install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al instalar i3lock-fancy."
fi
mark_task_completed "$log_action"

# Crear enlace simbólico batcat
log_action="Crear enlace simbólico batcat"
sudo ln -sf /usr/bin/bat /usr/bin/batcat > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al crear enlace simbólico para batcat."
fi
mark_task_completed "$log_action"

# Actualización final del sistema
log_action="Realizar actualización final del sistema"
sudo apt update > /dev/null 2>&1
if [ $? -ne 0 ]; then
    handle_error "$log_action" "Error al ejecutar 'apt update' final."
fi

# Intentar parrot-upgrade, si falla, usar apt upgrade
if ! parrot-upgrade -y > /dev/null 2>&1; then
    echo "Advertencia: 'parrot-upgrade' falló o no está disponible en la actualización final. Intentando 'apt upgrade'." >&2
    if ! sudo apt upgrade -y > /dev/null 2>&1; then
        handle_error "$log_action" "Error durante la actualización final del sistema con 'apt upgrade'."
    fi
fi
sudo apt autoremove -y > /dev/null 2>&1 # Limpia paquetes viejos
mark_task_completed "$log_action"

# Reiniciar sesión de usuario
log_action="Reiniciar sesión de usuario"
# No se ejecuta aquí, es una instrucción manual al final del script.
# Esto se marca como completado para que la checklist muestre el progreso.
mark_task_completed "$log_action"


clear_screen # Limpia la pantalla antes del mensaje final
echo "======================================================"
echo "          INSTALACIÓN COMPLETADA EXITOSAMENTE         "
echo "======================================================"
echo ""
echo "Todas las tareas han sido completadas."
echo "Para que los cambios surtan efecto, por favor, **reinicia tu sesión de usuario**."
echo ""
echo "¡Disfruta de tu nuevo entorno!"
