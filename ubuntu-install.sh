#!/bin/bash

# --- Funciones para la Checklist ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset
}

# Array de todas las tareas
declare -a ALL_TASKS=(
    "Verificar permisos de root"
    "Verificar conectividad a Internet"
    "Mostrar aviso inicial"
    "Instalar dependencias y herramientas generales (git, curl, etc.)"
    "Actualizar el sistema"
    "Instalar dependencias principales"
    "Definir directorio home del usuario"
    "Clonar bspwm y sxhkd"
    "Compilar e instalar bspwm"
    "Compilar e instalar sxhkd"
    "Instalar libxinerama1 y libxinerama-dev"
    "Instalar Kitty"
    "Crear directorios de configuración"
    "Copiar fondos de pantalla"
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
    "Finalizar y mostrar mensaje de éxito"
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

# Función para manejar errores y salir (si es necesario)
handle_error() {
    local task_name="$1"
    local error_message="$2"
    clear_screen
    echo "¡ERROR FATAL!"
    echo "Falló la tarea: $task_name"
    echo "Mensaje: $error_message"
    echo "Abortando el script. Por favor, revisa el mensaje de error para más detalles."
    exit 1
}

# Función para verificar la conexión a Internet
check_internet_connection() {
    local log_action="Verificar conectividad a Internet"
    echo "Comprobando conexión a Internet..."
    if ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1 || ping -c 1 -W 3 github.com > /dev/null 2>&1; then
        echo "Conexión a Internet detectada."
    else
        handle_error "$log_action" "No se pudo establecer una conexión a Internet. Por favor, verifica tu conexión de red antes de continuar."
    fi
    mark_task_completed "$log_action"
}

# --- Inicio del Script Principal ---

# Captura de Ctrl+C
trap '
    clear_screen
    echo ""
    echo "❌ Atención: El script ha sido cancelado por el usuario."
    echo "La cancelación de la instalación en medio del proceso podría dejar"
    echo "tu entorno en un estado inestable o incompleto, requiriendo"
    echo "una intervención manual para corregirlo. Saliendo..."
    exit 1
' SIGINT

display_checklist

# Verificar permisos de root
log_action="Verificar permisos de root"
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root. Por favor, ejecuta: sudo ./install.sh"
    exit 1
fi
mark_task_completed "$log_action"

# Realizar comprobación de Internet
check_internet_connection

# Determinar el usuario no root
if [ -z "$SUDO_USER" ]; then
    handle_error "Definir directorio home del usuario" "No se pudo determinar el nombre del usuario no root. Por favor, ejecuta el script con 'sudo'."
else
    REAL_USER="$SUDO_USER"
fi

# Definir el directorio del repositorio
REPO_DIR="$(dirname "$(realpath "$0")")"
if [ ! -d "$REPO_DIR" ]; then
    handle_error "Definir directorio home del usuario" "No se pudo encontrar el directorio del repositorio: $REPO_DIR. Asegúrate de ejecutar el script desde la carpeta correcta."
fi

# Mensaje de información para el usuario y espera
clear_screen
echo "======================================================"
echo "          INICIO DE LA INSTALACIÓN DEL ENTORNO        "
echo "======================================================"
echo ""
echo "Este script instalará un entorno completo en Ubuntu. Asegúrate de tener espacio suficiente y una conexión a Internet estable."
echo ""
echo "Presiona Enter para continuar con la instalación..."
read -r

mark_task_completed "Mostrar aviso inicial"

# Instalar herramientas generales
log_action="Instalar dependencias y herramientas generales (git, curl, etc.)"
echo "Instalando herramientas de desarrollo y utilidades esenciales (git, curl, wget, neovim)..."
if ! apt install -y git curl wget neovim net-tools; then
    echo "Advertencia: Falló la instalación de herramientas esenciales." >&2
fi
mark_task_completed "$log_action"

# Actualizar el sistema
log_action="Actualizar el sistema"
echo "Realizando 'apt update'..."
if ! apt update -y; then
    echo "Advertencia: 'apt update' falló. Intentando continuar." >&2
fi
echo "Realizando 'apt upgrade'..."
if ! apt upgrade -y; then
    echo "Advertencia: 'apt upgrade' falló. El sistema puede no estar completamente actualizado." >&2
fi
apt autoremove -y
mark_task_completed "$log_action"

# Instalar dependencias principales
log_action="Instalar dependencias principales"
deps=(
    build-essential git vim libxcb-util0-dev libxcb-ewmh-dev
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev
    libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
    libxcb-shape0-dev libxcb-xinput-dev pkg-config
)
echo "Instalando dependencias principales: ${deps[*]}..."
if ! apt install -y "${deps[@]}"; then
    echo "Advertencia: La instalación de dependencias principales falló." >&2
fi
mark_task_completed "$log_action"

# Definir directorio home del usuario
log_action="Definir directorio home del usuario"
user_home=$(getent passwd "$REAL_USER" | cut -d: -f6)
if [ -z "$user_home" ]; then
    handle_error "$log_action" "No se pudo obtener el directorio home para el usuario $REAL_USER."
fi
echo "Directorio home del usuario ($REAL_USER): $user_home"
mark_task_completed "$log_action"

# Clonar bspwm y sxhkd
log_action="Clonar bspwm y sxhkd"
cd "$user_home" || handle_error "$log_action" "No se pudo cambiar al directorio home del usuario: $user_home."
if [ -d "bspwm" ]; then
    echo "El directorio bspwm ya existe. Saltando clonación."
else
    echo "Clonando bspwm..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/baskerville/bspwm.git; then
        handle_error "$log_action" "Error al clonar bspwm."
    fi
fi
if [ -d "sxhkd" ]; then
    echo "El directorio sxhkd ya existe. Saltando clonación."
else
    echo "Clonando sxhkd..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/baskerville/sxhkd.git; then
        handle_error "$log_action" "Error al clonar sxhkd."
    fi
fi
mark_task_completed "$log_action"

# Compilar e instalar bspwm
log_action="Compilar e instalar bspwm"
cd "$user_home/bspwm" || handle_error "$log_action" "No se pudo cambiar al directorio de bspwm."
echo "Compilando bspwm..."
if ! sudo -u "$REAL_USER" make; then handle_error "$log_action" "Error al compilar bspwm."; fi
echo "Instalando bspwm..."
if ! make install; then handle_error "$log_action" "Error al instalar bspwm."; fi
mark_task_completed "$log_action"

# Compilar e instalar sxhkd
log_action="Compilar e instalar sxhkd"
cd "$user_home/sxhkd" || handle_error "$log_action" "No se pudo cambiar al directorio de sxhkd."
echo "Compilando sxhkd..."
if ! sudo -u "$REAL_USER" make; then handle_error "$log_action" "Error al compilar sxhkd."; fi
echo "Instalando sxhkd..."
if ! make install; then handle_error "$log_action" "Error al instalar sxhkd."; fi
mark_task_completed "$log_action"

# Instalar libxinerama
log_action="Instalar libxinerama1 y libxinerama-dev"
echo "Instalando libxinerama1 y libxinerama-dev..."
if ! apt install -y libxinerama1 libxinerama-dev; then
    echo "Advertencia: Falló la instalación de libxinerama." >&2
fi
mark_task_completed "$log_action"

# Instalar Kitty
log_action="Instalar Kitty"
echo "Instalando Kitty..."
if ! apt install -y kitty; then
    echo "Advertencia: Falló la instalación de Kitty." >&2
fi
mark_task_completed "$log_action"

# Crear directorios de configuración
log_action="Crear directorios de configuración"
echo "Creando directorios de configuración..."
if ! sudo -u "$REAL_USER" mkdir -p \
    "$user_home/.config/bspwm" \
    "$user_home/.config/sxhkd" \
    "$user_home/.config/bspwm/scripts" \
    "$user_home/fondos"; then
    handle_error "$log_action" "Error al crear directorios de configuración."
fi
mark_task_completed "$log_action"

# Copiar fondos de pantalla
log_action="Copiar fondos de pantalla"
echo "Copiando fondos de pantalla..."
if ! sudo -u "$REAL_USER" cp -r "$REPO_DIR/fondos/"* "$user_home/fondos/"; then
    handle_error "$log_action" "Error al copiar fondos."
fi
mark_task_completed "$log_action"

# Copiar configuración de bspwm y sxhkd
log_action="Copiar archivos de configuración de bspwm y sxhkd"
echo "Copiando archivos de configuración de bspwm y sxhkd..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/bspwm/bspwmrc" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar bspwmrc."; fi
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/bspwm/setup_monitors.sh" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar setup_monitors.sh."; fi
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/bspwm/setup_monitorsPortatil.sh" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar setup_monitorsPortatil.sh."; fi
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/"; then handle_error "$log_action" "Error al copiar sxhkdrc."; fi
mark_task_completed "$log_action"

# Copiar bspwm_resize
log_action="Copiar y hacer ejecutable bspwm_resize"
echo "Copiando y haciendo ejecutable bspwm_resize..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/bspwm/scripts/bspwm_resize" "$user_home/.config/bspwm/scripts/"; then
    handle_error "$log_action" "Error al copiar bspwm_resize."
fi
if ! sudo -u "$REAL_USER" chmod +x "$user_home/.config/bspwm/bspwmrc"; then handle_error "$log_action" "Error al dar permisos a bspwmrc."; fi
if ! sudo -u "$REAL_USER" chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize"; then handle_error "$log_action" "Error al dar permisos a bspwm_resize."; fi
mark_task_completed "$log_action"

# Instalar dependencias para Polybar
log_action="Instalar dependencias adicionales para Polybar"
echo "Instalando dependencias adicionales para Polybar..."
if ! apt install -y \
    cmake cmake-data pkg-config python3-sphinx \
    libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libxcb-randr0-dev libxcb-composite0-dev \
    python3-xcbgen xcb-proto libxcb-image0-dev \
    libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev \
    libxcb-cursor-dev libasound2-dev libpulse-dev \
    libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev \
    libxcb-xinput-dev; then
    echo "Advertencia: Falló la instalación de algunas dependencias de Polybar." >&2
fi
mark_task_completed "$log_action"

# Descargar e instalar Polybar
log_action="Descargar y instalar Polybar"
echo "Preparando para descargar e instalar Polybar..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/Downloads"; then handle_error "$log_action" "No se pudo crear el directorio Downloads."; fi
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads."
if [ -d "polybar" ]; then
    echo "El directorio polybar ya existe. Saltando clonación."
else
    echo "Clonando Polybar..."
    if ! sudo -u "$REAL_USER" git clone --recursive https://github.com/polybar/polybar; then handle_error "$log_action" "Error al clonar Polybar."; fi
fi
cd polybar && sudo -u "$REAL_USER" mkdir -p build && cd build || handle_error "$log_action" "No se pudo preparar el directorio de Polybar."
echo "Ejecutando cmake para Polybar..."
if ! sudo -u "$REAL_USER" cmake ..; then handle_error "$log_action" "Error al ejecutar cmake para Polybar."; fi
echo "Compilando Polybar..."
if ! sudo -u "$REAL_USER" make -j"$(nproc)"; then handle_error "$log_action" "Error al compilar Polybar."; fi
echo "Instalando Polybar..."
if ! make install; then handle_error "$log_action" "Error al instalar Polybar."; fi
mark_task_completed "$log_action"

# Instalar dependencias Picom
log_action="Instalar dependencias de Picom"
echo "Instalando dependencias de Picom..."
if ! apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev \
    libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-render-util0-dev libxcb-render0-dev \
    libxcb-composite0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-xinerama0-dev \
    libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev \
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev; then
    echo "Advertencia: Falló la instalación de dependencias de Picom." >&2
fi
mark_task_completed "$log_action"

# Instalar libpcre3
log_action="Instalar libpcre3 y libpcre3-dev"
echo "Instalando libpcre3 y libpcre3-dev..."
if ! apt install -y libpcre3 libpcre3-dev; then
    echo "Advertencia: Falló la instalación de libpcre3." >&2
fi
mark_task_completed "$log_action"

# Descargar e instalar Picom
log_action="Descargar y instalar Picom"
echo "Preparando para descargar e instalar Picom..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads."
if [ -d "picom" ]; then
    echo "El directorio picom ya existe. Saltando clonación."
else
    echo "Clonando Picom..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/ibhagwan/picom.git; then handle_error "$log_action" "Error al clonar Picom."; fi
fi
cd picom || handle_error "$log_action" "No se pudo cambiar al directorio de Picom."
echo "Actualizando submódulos de Picom..."
if ! sudo -u "$REAL_USER" git submodule update --init --recursive; then handle_error "$log_action" "Error al actualizar submódulos de Picom."; fi
echo "Configurando meson para Picom..."
if ! sudo -u "$REAL_USER" meson --buildtype=release . build; then handle_error "$log_action" "Error al configurar meson para Picom."; fi
echo "Compilando Picom..."
if ! sudo -u "$REAL_USER" ninja -C build; then handle_error "$log_action" "Error al compilar Picom."; fi
echo "Instalando Picom..."
if ! ninja -C build install; then handle_error "$log_action" "Error al instalar Picom."; fi
mark_task_completed "$log_action"

# Instalar Rofi
log_action="Instalar Rofi"
echo "Instalando Rofi..."
if ! apt install -y rofi; then echo "Advertencia: Falló la instalación de Rofi." >&2; fi
mark_task_completed "$log_action"

# Instalar bspwm desde los repositorios
log_action="Instalar bspwm desde los repositorios"
echo "Instalando bspwm desde los repositorios..."
if ! apt install -y bspwm; then echo "Advertencia: Falló la instalación de bspwm desde el repositorio." >&2; fi
mark_task_completed "$log_action"

# Copiar fuentes personalizadas
log_action="Copiar fuentes personalizadas"
echo "Copiando fuentes personalizadas..."
if ! cp -r "$REPO_DIR/fonts/"* /usr/local/share/fonts/; then
    handle_error "$log_action" "Error al copiar fuentes."
fi
mark_task_completed "$log_action"

# Copiar configuración de Kitty
log_action="Copiar configuración de Kitty"
echo "Copiando configuración de Kitty para el usuario..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/kitty"; then handle_error "$log_action" "Error al crear directorio de config de Kitty."; fi
if ! sudo -u "$REAL_USER" cp -r "$REPO_DIR/Config/kitty/." "$user_home/.config/kitty/"; then
    handle_error "$log_action" "Error al copiar config de Kitty."
fi
mark_task_completed "$log_action"

# Instalar Zsh y plugins
log_action="Instalar Zsh"
echo "Instalando Zsh..."
if ! apt install -y zsh; then echo "Advertencia: Falló la instalación de Zsh." >&2; fi
mark_task_completed "$log_action"

log_action="Instalar complementos de Zsh"
echo "Instalando complementos de Zsh..."
if ! apt install -y zsh-autosuggestions zsh-syntax-highlighting; then
    echo "Advertencia: Falló la instalación de zsh-autosuggestions o zsh-syntax-highlighting." >&2
fi
mark_task_completed "$log_action"

# Copiar configuración de Kitty a root
log_action="Copiar configuración de Kitty a root"
echo "Copiando configuración de Kitty para root..."
if ! mkdir -p /root/.config/kitty; then handle_error "$log_action" "Error al crear directorio de config de Kitty para root."; fi
if ! cp -r "$user_home/.config/kitty/." /root/.config/kitty/; then
    handle_error "$log_action" "Error al copiar config de Kitty para root."
fi
mark_task_completed "$log_action"

# Instalar utilidades
log_action="Instalar feh"
echo "Instalando feh..."
if ! apt install -y feh; then echo "Advertencia: Falló la instalación de feh." >&2; fi
mark_task_completed "$log_action"

log_action="Instalar ImageMagick"
echo "Instalando ImageMagick..."
if ! apt install -y imagemagick; then echo "Advertencia: Falló la instalación de ImageMagick." >&2; fi
mark_task_completed "$log_action"

log_action="Instalar Scrub"
echo "Instalando Scrub..."
if ! apt install -y scrub; then echo "Advertencia: Falló la instalación de Scrub." >&2; fi
mark_task_completed "$log_action"

# Clonar blue-sky
log_action="Clonar repositorio blue-sky"
echo "Clonando repositorio blue-sky..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads."
if [ -d "blue-sky" ]; then
    echo "El directorio blue-sky ya existe. Saltando clonación."
else
    echo "Clonando blue-sky..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/VaughnValle/blue-sky "$user_home/Downloads/blue-sky"; then
        handle_error "$log_action" "Error al clonar blue-sky."
    fi
fi
mark_task_completed "$log_action"

# Crear y copiar Polybar config
log_action="Crear directorio de configuración de Polybar"
echo "Creando directorio de configuración de Polybar..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/polybar"; then handle_error "$log_action" "Error al crear directorio de Polybar."; fi
mark_task_completed "$log_action"

log_action="Copiar archivos de configuración de Polybar"
echo "Copiando archivos de configuración de Polybar..."
if ! sudo -u "$REAL_USER" cp -a "$REPO_DIR/Config/polybar/." "$user_home/.config/polybar/"; then
    handle_error "$log_action" "Error al copiar config de Polybar."
fi
mark_task_completed "$log_action"

# Copiar fuentes de Polybar y actualizar caché
log_action="Copiar fuentes de Polybar"
echo "Copiando fuentes de Polybar..."
if ! cp -r "$REPO_DIR/Config/polybar/fonts/"* /usr/share/fonts/truetype/; then
    handle_error "$log_action" "Error al copiar fuentes de Polybar."
fi
mark_task_completed "$log_action"

log_action="Actualizar caché de fuentes"
echo "Actualizando caché de fuentes..."
if ! fc-cache -f -v; then
    echo "Advertencia: Falló la actualización de la caché de fuentes." >&2
fi
mark_task_completed "$log_action"

# Crear y copiar Picom conf
log_action="Crear directorio de configuración de Picom"
echo "Creando directorio de configuración de Picom..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/picom"; then handle_error "$log_action" "Error al crear directorio de Picom."; fi
mark_task_completed "$log_action"

log_action="Copiar archivo de configuración de Picom"
echo "Copiando archivo de configuración de Picom..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/picom/picom.conf" "$user_home/.config/picom/"; then
    handle_error "$log_action" "Error al copiar config de Picom."
fi
mark_task_completed "$log_action"

# Instalar Fastfetch
log_action="Instalar Fastfetch"
echo "Preparando para descargar e instalar Fastfetch..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads."
if [ -d "fastfetch" ]; then
    echo "El directorio fastfetch ya existe. Saltando clonación."
else
    echo "Clonando Fastfetch..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/fastfetch-cli/fastfetch.git; then handle_error "$log_action" "Error al clonar Fastfetch."; fi
fi
cd fastfetch || handle_error "$log_action" "No se pudo cambiar al directorio de Fastfetch."
echo "Configurando cmake para Fastfetch..."
if ! sudo -u "$REAL_USER" cmake -B build -DCCMAKE_BUILD_TYPE=Release; then handle_error "$log_action" "Error al configurar cmake para Fastfetch."; fi
echo "Compilando Fastfetch..."
if ! sudo -u "$REAL_USER" cmake --build build --config Release --target fastfetch; then handle_error "$log_action" "Error al compilar Fastfetch."; fi
echo "Instalando Fastfetch en /usr/local/bin..."
if ! cp build/fastfetch /usr/local/bin/; then handle_error "$log_action" "Error al instalar Fastfetch."; fi
mark_task_completed "$log_action"

# Configurar Powerlevel10k
log_action="Configurar Powerlevel10k para usuario"
echo "Configurando Powerlevel10k para el usuario..."
if [ -d "$user_home/powerlevel10k" ]; then
    echo "El directorio powerlevel10k ya existe para el usuario. Saltando clonación."
else
    echo "Clonando Powerlevel10k para el usuario..."
    if ! sudo -u "$REAL_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"; then handle_error "$log_action" "Error al clonar powerlevel10k para el usuario."; fi
fi
if ! grep -q 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' "$user_home/.zshrc"; then
    echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' | sudo -u "$REAL_USER" tee -a "$user_home/.zshrc";
fi
mark_task_completed "$log_action"

log_action="Configurar Powerlevel10k para root"
echo "Configurando Powerlevel10k para root..."
if [ -d "/root/powerlevel10k" ]; then
    echo "El directorio powerlevel10k ya existe para root. Saltando clonación."
else
    echo "Clonando Powerlevel10k para root..."
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k; then handle_error "$log_action" "Error al clonar powerlevel10k para root."; fi
fi
if ! grep -q 'source /root/powerlevel10k/powerlevel10k.zsh-theme' /root/.zshrc; then
    echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' | tee -a /root/.zshrc;
fi
mark_task_completed "$log_action"

# Copiar .zshrc de usuario y root
log_action="Copiar .zshrc de usuario"
echo "Copiando .zshrc de usuario..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/zshrc/user/.zshrc" "$user_home/.zshrc"; then handle_error "$log_action" "Error al copiar .zshrc de usuario."; fi
mark_task_completed "$log_action"

log_action="Ajustar permisos de .zshrc de usuario"
echo "Ajustando permisos de .zshrc de usuario..."
if ! chown "$REAL_USER":"$REAL_USER" "$user_home/.zshrc"; then handle_error "$log_action" "Error al cambiar propietario de .zshrc de usuario."; fi
if ! chmod 644 "$user_home/.zshrc"; then handle_error "$log_action" "Error al cambiar permisos de .zshrc de usuario."; fi
mark_task_completed "$log_action"

log_action="Copiar .zshrc de root"
echo "Copiando .zshrc de root..."
if ! cp "$REPO_DIR/Config/zshrc/root/.zshrc" /root/.zshrc; then handle_error "$log_action" "Error al copiar .zshrc de root."; fi
if ! chown root:root /root/.zshrc; then handle_error "$log_action" "Error al cambiar propietario de .zshrc de root."; fi
if ! chmod 644 /root/.zshrc; then handle_error "$log_action" "Error al cambiar permisos de .zshrc de root."; fi
mark_task_completed "$log_action"

# Instalar bat y lsd (.deb)
log_action="Copiar archivos de lsd"
echo "Copiando archivos .deb de lsd y bat a Downloads..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/Downloads"; then handle_error "$log_action" "No se pudo crear el directorio Downloads."; fi
if ! sudo -u "$REAL_USER" cp -a "$REPO_DIR/lsd/." "$user_home/Downloads/"; then handle_error "$log_action" "Error al copiar archivos de lsd."; fi
mark_task_completed "$log_action"

log_action="Instalar bat y lsd"
echo "Instalando bat..."
if ! dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb"; then
    echo "Advertencia: Falló la instalación de bat. Intentando resolver dependencias faltantes." >&2
    apt --fix-broken install -y
fi
echo "Instalando lsd..."
if ! dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb"; then
    echo "Advertencia: Falló la instalación de lsd. Intentando resolver dependencias faltantes." >&2
    apt --fix-broken install -y
fi
mark_task_completed "$log_action"

# Actualizar .p10k.zsh
log_action="Actualizar .p10k.zsh de usuario"
echo "Copiando .p10k.zsh para el usuario..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/Config/Power10kNormal/.p10k.zsh" "$user_home/.p10k.zsh"; then handle_error "$log_action" "Error al actualizar .p10k.zsh de usuario."; fi
mark_task_completed "$log_action"

log_action="Actualizar .p10k.zsh de root"
echo "Copiando .p10k.zsh para root..."
if ! cp "$REPO_DIR/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh; then handle_error "$log_action" "Error al actualizar .p10k.zsh de root."; fi
mark_task_completed "$log_action"

# Copiar scripts personalizados a bin
log_action="Crear directorio bin en .config"
echo "Creando directorio bin en .config..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/bin"; then handle_error "$log_action" "Error al crear el directorio bin."; fi
mark_task_completed "$log_action"

log_action="Copiar y dar permisos a scripts personalizados"
echo "Copiando scripts personalizados y asignando permisos de ejecución..."
if ! sudo -u "$REAL_USER" cp "$REPO_DIR/bin/"* "$user_home/.config/bin/"; then handle_error "$log_action" "Error al copiar scripts personalizados."; fi
if ! sudo -u "$REAL_USER" chmod +x "$user_home/.config/bin/"*; then handle_error "$log_action" "Error al dar permisos a scripts personalizados."; fi
mark_task_completed "$log_action"

# Instalar y configurar sudo-plugin
log_action="Crear directorio zsh-sudo-plugin"
echo "Creando directorio para zsh-sudo-plugin..."
if ! mkdir -p /usr/share/zsh-sudo-plugin; then handle_error "$log_action" "Error al crear directorio zsh-sudo-plugin."; fi
mark_task_completed "$log_action"

log_action="Copiar y configurar sudo.plugin.zsh"
echo "Copiando y configurando sudo.plugin.zsh..."
if ! cp "$REPO_DIR/sudoPlugin/sudo.plugin.zsh" /usr/share/zsh-sudo-plugin/; then handle_error "$log_action" "Error al copiar sudo.plugin.zsh."; fi
if ! chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh; then handle_error "$log_action" "Error al dar permisos a sudo.plugin.zsh."; fi
mark_task_completed "$log_action"

# Instalar utilidades
log_action="Instalar npm"
echo "Instalando npm..."
if ! apt install -y npm; then echo "Advertencia: Falló la instalación de npm." >&2; fi
mark_task_completed "$log_action"

log_action="Instalar Flameshot"
echo "Instalando Flameshot..."
if ! apt install -y flameshot; then echo "Advertencia: Falló la instalación de Flameshot." >&2; fi
mark_task_completed "$log_action"

log_action="Instalar i3lock"
echo "Instalando i3lock..."
if ! apt install -y i3lock; then echo "Advertencia: Falló la instalación de i3lock." >&2; fi
mark_task_completed "$log_action"

# Clonar e instalar i3lock-fancy
log_action="Clonar e instalar i3lock-fancy"
echo "Preparando para clonar e instalar i3lock-fancy..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads."
if [ -d "i3lock-fancy" ]; then
    echo "El directorio i3lock-fancy ya existe. Saltando clonación."
else
    echo "Clonando i3lock-fancy..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/meskarune/i3lock-fancy.git; then handle_error "$log_action" "Error al clonar i3lock-fancy."; fi
fi
cd i3lock-fancy || handle_error "$log_action" "No se pudo cambiar al directorio de i3lock-fancy."
echo "Instalando i3lock-fancy..."
if ! make install; then handle_error "$log_action" "Error al instalar i3lock-fancy."; fi
mark_task_completed "$log_action"

# Crear enlace simbólico batcat
log_action="Crear enlace simbólico batcat"
echo "Creando enlace simbólico para 'batcat'..."
if command -v bat &> /dev/null && [ ! -f "/usr/bin/batcat" ]; then
    if ! ln -s /usr/bin/bat /usr/bin/batcat; then echo "Advertencia: Falló la creación del enlace simbólico para batcat." >&2; fi
else
    echo "Bat no está instalado o el enlace batcat ya existe. Saltando."
fi
mark_task_completed "$log_action"

# Actualización final del sistema
log_action="Realizar actualización final del sistema"
echo "Realizando 'apt update' y 'apt upgrade' finales..."
if ! apt update -y; then echo "Advertencia: 'apt update' final falló." >&2; fi
if ! apt upgrade -y; then echo "Advertencia: 'apt upgrade' final falló." >&2; fi
apt autoremove -y
mark_task_completed "$log_action"

# Mensaje final de entorno listo
log_action="Finalizar y mostrar mensaje de éxito"
clear_screen
echo "======================================================"
echo "          ¡EL ENTORNO ESTÁ LISTO!                   "
echo "======================================================"
echo ""
echo "¡Felicidades! La instalación y configuración de tu entorno han finalizado exitosamente."
echo "Para que todos los cambios surtan efecto por completo, te recomendamos encarecidamente"
echo "que **reinicies tu sesión actual** o, idealmente, **reinicies el sistema completo**."
echo ""
read -p "Presiona Enter para finalizar el script y cerrar esta terminal..."

mark_task_completed "$log_action"

exit 0
