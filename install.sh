#!/bin/bash

# --- Funciones para la Checklist ---

# Limpia la pantalla de la terminal
clear_screen() {
    tput reset # Más robusto que 'clear'
}

# Array de todas las tareas
declare -a ALL_TASKS=(
    "Verificar permisos de root"
    "Verificar conectividad a Internet"
    "Mostrar aviso inicial"
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
        end
        
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
    # Intentar hacer ping a Google DNS y GitHub
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
    echo "una intervención manual para corregirlo. Se recomienda ejecutar el script de limpieza o restaurar un punto anterior."
    echo "Saliendo..."
    exit 1
' SIGINT

display_checklist # Muestra la checklist inicial vacía

# Verificar permisos de root
log_action="Verificar permisos de root"
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root. Por favor, ejecuta: sudo ./install.sh"
    exit 1
fi
mark_task_completed "$log_action"

# Realizar comprobación de Internet
check_internet_connection

# Determinar el usuario no root. Es crucial para instalar cosas en su home.
# SUDO_USER es la forma más común, pero añadimos LOGNAME y USER como fallback.
if [ -z "$SUDO_USER" ]; then
    if [ -n "$LOGNAME" ] && [ "$LOGNAME" != "root" ]; then
        REAL_USER="$LOGNAME"
    elif [ -n "$USER" ] && [ "$USER" != "root" ]; then
        REAL_USER="$USER"
    else
        handle_error "Definir directorio home del usuario" "No se pudo determinar el nombre del usuario no root. Por favor, ejecuta el script con 'sudo' y asegúrate de que estés en una sesión de usuario válida."
    fi
else
    REAL_USER="$SUDO_USER"
fi

# Mensaje de información para el usuario y espera
clear_screen # Limpia antes de mostrar el mensaje
echo "======================================================"
echo "          INICIO DE LA INSTALACIÓN DEL ENTORNO        "
echo "======================================================"
echo ""
echo "¡Atención! RECUERDA CREAR UN PUNTO DE RESTAURACIÓN ANTES DE INSTALAR"
echo "Este script instalará un entorno completo. Asegúrate de tener espacio suficiente y una conexión a Internet estable."
echo "Este proceso de instalación puede tardar aproximadamente 10 minutos o más, dependiendo de tu conexión y hardware."
echo "Por favor, no cierres la terminal ni interrumpas el script (Ctrl+C), a menos que sea absolutamente necesario."
echo "La cancelación de la instalación en medio del proceso podría dejar"
echo "tu entorno en un estado inestable o incompleto, requiriendo"
echo "una intervención manual para corregirlo. Si necesitas cancelar, considera usar el script de limpieza después."
echo ""
echo "Presiona Enter para continuar con la instalación..."
read -r # Espera a que el usuario presione Enter

mark_task_completed "Mostrar aviso inicial" # Marca la tarea de aviso como completada

# Actualizar el sistema
log_action="Actualizar el sistema"
echo "Realizando 'apt update'..."
if ! apt update > /dev/null 2>&1; then
    echo "Advertencia: 'apt update' falló. Esto puede indicar problemas con los repositorios o la red, pero el script intentará continuar." >&2
fi

echo "Intentando 'parrot-upgrade' o 'apt upgrade'..."
if command -v parrot-upgrade &> /dev/null; then # Comprueba si parrot-upgrade existe
    if ! parrot-upgrade -y > /dev/null 2>&1; then
        echo "Advertencia: 'parrot-upgrade' falló. Intentando 'apt upgrade'." >&2
        if ! apt upgrade -y > /dev/null 2>&1; then
            echo "Advertencia: 'apt upgrade' también falló. El sistema puede no estar completamente actualizado." >&2
        fi
    fi
else
    echo "Parrot-upgrade no encontrado. Ejecutando 'apt upgrade'."
    if ! apt upgrade -y > /dev/null 2>&1; then
        echo "Advertencia: 'apt upgrade' falló. El sistema puede no estar completamente actualizado." >&2
    fi
fi
apt autoremove -y > /dev/null 2>&1 # Limpia paquetes viejos
mark_task_completed "$log_action"

# Instalar dependencias principales
log_action="Instalar dependencias principales"
deps=(
    build-essential git vim libxcb-util0-dev libxcb-ewmh-dev
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev
    libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
    libxcb-shape0-dev libxcb-xinput-dev # Añadida libxcb-xinput-dev
    pkg-config
)
echo "Instalando dependencias principales: ${deps[*]}..."
for dep in "${deps[@]}"; do
    if ! apt install -y "$dep" > /dev/null 2>&1; then
        echo "Advertencia: La dependencia '$dep' no se instaló correctamente. Esto podría causar problemas más adelante." >&2
    fi
done
mark_task_completed "$log_action"

# Definir directorio home del usuario
log_action="Definir directorio home del usuario"
# Ya REAL_USER ha sido definido previamente
user_home=$(getent passwd "$REAL_USER" | cut -d: -f6)
if [ -z "$user_home" ]; then
    handle_error "$log_action" "No se pudo obtener el directorio home para el usuario $REAL_USER. Asegúrate de que el usuario existe."
fi
echo "Directorio home del usuario ($REAL_USER): $user_home"
mark_task_completed "$log_action"

# Clonar bspwm y sxhkd
log_action="Clonar bspwm y sxhkd"
cd "$user_home" || handle_error "$log_action" "No se pudo cambiar al directorio home del usuario: $user_home. Verifica los permisos o si el directorio existe."

# --- Comprobación y Clonación de bspwm ---
if [ -d "$user_home/bspwm" ]; then
    echo "El directorio $user_home/bspwm ya existe. Saltando clonación de bspwm."
else
    echo "Clonando bspwm desde https://github.com/baskerville/bspwm.git en $user_home..."
    # Ejecuta git clone como el usuario no privilegiado para que los archivos tengan su propiedad.
    if ! sudo -u "$REAL_USER" git clone https://github.com/baskerville/bspwm.git; then
        handle_error "$log_action" "Error al clonar bspwm. Revisa la conexión a Internet o los permisos."
    fi
fi

# --- Comprobación y Clonación de sxhkd ---
if [ -d "$user_home/sxhkd" ]; then
    echo "El directorio $user_home/sxhkd ya existe. Saltando clonación de sxhkd."
else
    echo "Clonando sxhkd desde https://github.com/baskerville/sxhkd.git en $user_home..."
    # Ejecuta git clone como el usuario no privilegiado para que los archivos tengan su propiedad.
    if ! sudo -u "$REAL_USER" git clone https://github.com/baskerville/sxhkd.git; then
        handle_error "$log_action" "Error al clonar sxhkd. Revisa la conexión a Internet o los permisos."
    fi
fi
mark_task_completed "$log_action"

# Compilar e instalar bspwm
log_action="Compilar e instalar bspwm"
cd "$user_home/bspwm" || handle_error "$log_action" "No se pudo cambiar al directorio de bspwm. Asegúrate de que bspwm fue clonado correctamente."
echo "Compilando bspwm (la salida de 'make' será visible)..."
# Ejecutar make como el usuario no privilegiado
if ! sudo -u "$REAL_USER" make; then
    handle_error "$log_action" "Error al compilar bspwm. Revisa la salida anterior para dependencias faltantes o errores de compilación."
fi
echo "Instalando bspwm..."
# Ejecutar make install como root
if ! make install; then
    handle_error "$log_action" "Error al instalar bspwm. Revisa los logs."
fi
mark_task_completed "$log_action"

# Compilar e instalar sxhkd
log_action="Compilar e instalar sxhkd"
cd "$user_home/sxhkd" || handle_error "$log_action" "No se pudo cambiar al directorio de sxhkd. Asegúrate de que sxhkd fue clonado correctamente."
echo "Compilando sxhkd (la salida de 'make' será visible)..."
# Ejecutar make como el usuario no privilegiado
if ! sudo -u "$REAL_USER" make; then
    handle_error "$log_action" "Error al compilar sxhkd. Revisa la salida anterior para dependencias faltantes o errores de compilación."
fi
echo "Instalando sxhkd..."
# Ejecutar make install como root
if ! make install; then
    handle_error "$log_action" "Error al instalar sxhkd. Revisa los logs."
fi
mark_task_completed "$log_action"

# Instalar libxinerama
log_action="Instalar libxinerama1 y libxinerama-dev"
echo "Instalando libxinerama1 y libxinerama-dev..."
if ! apt install -y libxinerama1 libxinerama-dev > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de libxinerama. Esto podría afectar el funcionamiento de algunas aplicaciones." >&2
fi
mark_task_completed "$log_action"

# Instalar Kitty
log_action="Instalar Kitty"
echo "Instalando Kitty..."
if ! apt install -y kitty > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de Kitty. Es posible que tengas que instalarlo manualmente." >&2
fi
mark_task_completed "$log_action"

# Crear directorios de configuración
log_action="Crear directorios de configuración"
echo "Creando directorios de configuración para el usuario: .config/bspwm, .config/sxhkd, .config/bspwm/scripts, fondos..."
if ! sudo -u "$REAL_USER" mkdir -p \
    "$user_home/.config/bspwm" \
    "$user_home/.config/sxhkd" \
    "$user_home/.config/bspwm/scripts" \
    "$user_home/fondos"; then
    handle_error "$log_action" "Error al crear directorios de configuración para el usuario. Verifica permisos o si el path del Entorno-Linux es correcto."
fi
mark_task_completed "$log_action"

# Copiar fondos de pantalla
log_action="Copiar fondos de pantalla"
echo "Copiando fondos de pantalla de '$user_home/Entorno-Linux/fondos/' a '$user_home/fondos/'..."
# Realizar la copia como el usuario, para asegurar permisos de lectura del origen y escritura en destino
if ! sudo -u "$REAL_USER" cp -r "$user_home/Entorno-Linux/fondos/"* "$user_home/fondos/"; then
    handle_error "$log_action" "Error al copiar fondos. Asegúrate de que '$user_home/Entorno-Linux/fondos/' exista y tenga permisos de lectura."
fi
mark_task_completed "$log_action"

# Copiar los archivos de configuración a las carpetas de configuración
log_action="Copiar archivos de configuración de bspwm y sxhkd"
echo "Copiando archivos de configuración de bspwm y sxhkd..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/bspwm/bspwmrc" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar bspwmrc. Asegúrate de que '$user_home/Entorno-Linux/Config/bspwm/bspwmrc' exista."; fi
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/bspwm/setup_monitors.sh" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar setup_monitors.sh. Asegúrate de que exista."; fi
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/bspwm/setup_monitorsPortatil.sh" "$user_home/.config/bspwm/"; then handle_error "$log_action" "Error al copiar setup_monitorsPortatil.sh. Asegúrate de que exista."; fi
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/sxhkd/sxhkdrc" "$user_home/.config/sxhkd/"; then handle_error "$log_action" "Error al copiar sxhkdrc. Asegúrate de que exista."; fi
mark_task_completed "$log_action"

# Copiar el script bspwm_resize al directorio de scripts
log_action="Copiar y hacer ejecutable bspwm_resize"
echo "Copiando y haciendo ejecutable bspwm_resize..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/bspwm/scripts/bspwm_resize" "$user_home/.config/bspwm/scripts/"; then
    handle_error "$log_action" "Error al copiar bspwm_resize. Asegúrate de que exista en '$user_home/Entorno-Linux/Config/bspwm/scripts/'."
fi
# Hacer ejecutable el script bspwmrc y bspwm_resize como el usuario
if ! sudo -u "$REAL_USER" chmod +x "$user_home/.config/bspwm/bspwmrc"; then handle_error "$log_action" "Error al dar permisos de ejecución a bspwmrc."; fi
if ! sudo -u "$REAL_USER" chmod +x "$user_home/.config/bspwm/scripts/bspwm_resize"; then handle_error "$log_action" "Error al dar permisos de ejecución a bspwm_resize."; fi
mark_task_completed "$log_action"

# Instalar paquetes adicionales necesarios para Polybar
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
    libxcb-xinput-dev > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de algunas dependencias de Polybar. Revisa la conexión o los repositorios." >&2
fi
mark_task_completed "$log_action"

# Descargar e instalar Polybar como usuario no privilegiado
log_action="Descargar y instalar Polybar"
echo "Preparando para descargar e instalar Polybar..."
# Crear directorio Downloads si no existe para el usuario
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/Downloads"; then
    handle_error "$log_action" "No se pudo crear el directorio Downloads ($user_home/Downloads) para el usuario."
fi
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads). Asegúrate de que el directorio existe y tiene permisos."

if [ -d "polybar" ]; then
    echo "El directorio polybar ya existe en Downloads. Saltando clonación."
else
    echo "Clonando Polybar desde https://github.com/polybar/polybar.git (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone --recursive https://github.com/polybar/polybar; then
        handle_error "$log_action" "Error al clonar Polybar. Revisa tu conexión a internet o los permisos."
    fi
fi

cd polybar && sudo -u "$REAL_USER" mkdir -p build && cd build || handle_error "$log_action" "No se pudo preparar el directorio de Polybar para la compilación."

echo "Ejecutando cmake para Polybar (la salida de cmake será visible)..."
if ! sudo -u "$REAL_USER" cmake ..; then
    handle_error "$log_action" "Error al ejecutar cmake para Polybar. Revisa la salida de cmake para dependencias faltantes."
fi
echo "Compilando Polybar (la salida de make será visible)..."
if ! sudo -u "$REAL_USER" make -j"$(nproc)"; then
    handle_error "$log_action" "Error al compilar Polybar. Revisa los logs de compilación."
fi
echo "Instalando Polybar..."
if ! make install; then
    handle_error "$log_action" "Error al instalar Polybar."
fi
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
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de dependencias de Picom. Revisa la conexión o los repositorios." >&2
fi
mark_task_completed "$log_action"

# Instalar libpcre3
log_action="Instalar libpcre3 y libpcre3-dev"
echo "Instalando libpcre3 y libpcre3-dev..."
if ! apt install -y libpcre3 libpcre3-dev > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de libpcre3. Asegúrate de que los repositorios estén correctos." >&2
fi
mark_task_completed "$log_action"

# Descargar e instalar Picom como usuario no privilegiado
log_action="Descargar y instalar Picom"
echo "Preparando para descargar e instalar Picom..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."

if [ -d "picom" ]; then
    echo "El directorio picom ya existe en Downloads. Saltando clonación."
else
    echo "Clonando Picom desde https://github.com/ibhagwan/picom.git (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/ibhagwan/picom.git; then
        handle_error "$log_action" "Error al clonar Picom. Revisa tu conexión a internet o los permisos."
    fi
fi

cd picom || handle_error "$log_action" "No se pudo cambiar al directorio de Picom."
echo "Actualizando submódulos de Picom (la salida será visible en caso de error)..."
if ! sudo -u "$REAL_USER" git submodule update --init --recursive; then
    handle_error "$log_action" "Error al actualizar submódulos de Picom. Revisa la conexión."
fi
echo "Configurando meson para Picom (la salida de meson será visible)..."
if ! sudo -u "$REAL_USER" meson --buildtype=release . build; then
    handle_error "$log_action" "Error al configurar meson para Picom. Revisa la salida para dependencias faltantes."
fi
echo "Compilando Picom (la salida de ninja será visible)..."
if ! sudo -u "$REAL_USER" ninja -C build; then
    handle_error "$log_action" "Error al compilar Picom. Revisa los logs de compilación."
fi
echo "Instalando Picom..."
if ! ninja -C build install; then
    handle_error "$log_action" "Error al instalar Picom."
fi
mark_task_completed "$log_action"

# Instalar Rofi
log_action="Instalar Rofi"
echo "Instalando Rofi..."
if ! apt install -y rofi > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de Rofi." >&2
fi
mark_task_completed "$log_action"

# Instalar bspwm desde repositorio (Esto puede ser redundante si ya se compiló, pero se mantiene si es necesario para dependencias o versión de repo)
log_action="Instalar bspwm desde los repositorios"
echo "Instalando bspwm desde los repositorios (si es necesario y no está ya instalado por compilación)..."
if ! apt install -y bspwm > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de bspwm desde el repositorio. Podría ser porque ya está instalado o hay problemas con los repos." >&2
fi
mark_task_completed "$log_action"

# Copiar fuentes personalizadas
log_action="Copiar fuentes personalizadas"
echo "Copiando fuentes personalizadas a /usr/local/share/fonts/..."
if ! cp -r "$user_home/Entorno-Linux/fonts/"* /usr/local/share/fonts/; then
    handle_error "$log_action" "Error al copiar fuentes. Asegúrate de que '$user_home/Entorno-Linux/fonts/' exista y tenga contenido. Puede que necesites crear el directorio /usr/local/share/fonts/ si no existe."
fi
mark_task_completed "$log_action"

# Copiar configuración de Kitty
log_action="Copiar configuración de Kitty"
echo "Copiando configuración de Kitty para el usuario..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/kitty"; then handle_error "$log_action" "Error al crear directorio de config de Kitty para el usuario."; fi
if ! sudo -u "$REAL_USER" cp -r "$user_home/Entorno-Linux/Config/kitty/." "$user_home/.config/kitty/"; then
    handle_error "$log_action" "Error al copiar config de Kitty para el usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/kitty/' exista."
fi
mark_task_completed "$log_action"

# Instalar Zsh y plugins
log_action="Instalar Zsh"
echo "Instalando Zsh..."
if ! apt install -y zsh > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de Zsh. Esto podría afectar el shell." >&2
fi
mark_task_completed "$log_action"

log_action="Instalar complementos de Zsh"
echo "Instalando complementos de Zsh (zsh-autosuggestions, zsh-syntax-highlighting)..."
if ! apt install -y zsh-autosuggestions zsh-syntax-highlighting > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de zsh-autosuggestions o zsh-syntax-highlighting." >&2
fi
mark_task_completed "$log_action"

# Copiar configuración de Kitty a root
log_action="Copiar configuración de Kitty a root"
echo "Copiando configuración de Kitty para root..."
if ! mkdir -p /root/.config/kitty; then handle_error "$log_action" "Error al crear directorio de config de Kitty para root."; fi
if ! cp -r "$user_home/.config/kitty/." /root/.config/kitty/; then
    handle_error "$log_action" "Error al copiar config de Kitty para root. Asegúrate de que '$user_home/.config/kitty/' exista y tenga permisos de lectura."
fi
mark_task_completed "$log_action"

# Instalar feh
log_action="Instalar feh"
echo "Instalando feh..."
if ! apt install -y feh > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de feh." >&2
fi
mark_task_completed "$log_action"

# Instalar ImageMagick
log_action="Instalar ImageMagick"
echo "Instalando ImageMagick..."
if ! apt install -y imagemagick > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de ImageMagick." >&2
fi
mark_task_completed "$log_action"

# Instalar Scrub
log_action="Instalar Scrub"
echo "Instalando Scrub..."
if ! apt install -y scrub > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de Scrub." >&2
fi
mark_task_completed "$log_action"

# Clonar blue-sky
log_action="Clonar repositorio blue-sky"
echo "Clonando repositorio blue-sky..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."
if [ -d "blue-sky" ]; then
    echo "El directorio blue-sky ya existe en Downloads. Saltando clonación."
else
    echo "Clonando blue-sky desde https://github.com/VaughnValle/blue-sky (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/VaughnValle/blue-sky "$user_home/Downloads/blue-sky"; then
        handle_error "$log_action" "Error al clonar blue-sky. Revisa tu conexión a internet o los permisos."
    fi
fi
mark_task_completed "$log_action"

# Crear y copiar Polybar config
log_action="Crear directorio de configuración de Polybar"
echo "Creando directorio de configuración de Polybar para el usuario..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/polybar"; then handle_error "$log_action" "Error al crear directorio de Polybar para el usuario."; fi
mark_task_completed "$log_action"

log_action="Copiar archivos de configuración de Polybar"
echo "Copiando archivos de configuración de Polybar..."
if ! sudo -u "$REAL_USER" cp -a "$user_home/Entorno-Linux/Config/polybar/." "$user_home/.config/polybar/"; then
    handle_error "$log_action" "Error al copiar config de Polybar. Asegúrate de que '$user_home/Entorno-Linux/Config/polybar/' exista."
fi
mark_task_completed "$log_action"

# Copiar fuentes de Polybar y actualizar caché
log_action="Copiar fuentes de Polybar"
echo "Copiando fuentes de Polybar a /usr/share/fonts/truetype/..."
if ! cp -r "$user_home/Entorno-Linux/Config/polybar/fonts/"* /usr/share/fonts/truetype/; then
    handle_error "$log_action" "Error al copiar fuentes de Polybar. Asegúrate de que '$user_home/Entorno-Linux/Config/polybar/fonts/' exista y tenga contenido."
fi
mark_task_completed "$log_action"

log_action="Actualizar caché de fuentes"
echo "Actualizando caché de fuentes..."
if ! fc-cache -f -v > /dev/null 2>&1; then
    echo "Advertencia: Falló la actualización de la caché de fuentes. Puede que las nuevas fuentes no estén disponibles inmediatamente." >&2
fi
mark_task_completed "$log_action"

# Crear y copiar Picom conf
log_action="Crear directorio de configuración de Picom"
echo "Creando directorio de configuración de Picom para el usuario..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/picom"; then handle_error "$log_action" "Error al crear directorio de Picom para el usuario."; fi
mark_task_completed "$log_action"

log_action="Copiar archivo de configuración de Picom"
echo "Copiando archivo de configuración de Picom..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/picom/picom.conf" "$user_home/.config/picom/"; then
    handle_error "$log_action" "Error al copiar config de Picom. Asegúrate de que '$user_home/Entorno-Linux/Config/picom/picom.conf' exista."
fi
mark_task_completed "$log_action"

# Instalar Fastfetch
log_action="Instalar Fastfetch"
echo "Preparando para descargar e instalar Fastfetch..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."

if [ -d "fastfetch" ]; then
    echo "El directorio fastfetch ya existe en Downloads. Saltando clonación."
else
    echo "Clonando Fastfetch desde https://github.com/fastfetch-cli/fastfetch.git (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/fastfetch-cli/fastfetch.git; then
        handle_error "$log_action" "Error al clonar Fastfetch. Revisa tu conexión a internet o los permisos."
    fi
fi

cd fastfetch || handle_error "$log_action" "No se pudo cambiar al directorio de Fastfetch."
echo "Configurando cmake para Fastfetch (la salida de cmake será visible)..."
if ! sudo -u "$REAL_USER" cmake -B build -DCCMAKE_BUILD_TYPE=Release; then
    handle_error "$log_action" "Error al configurar cmake para Fastfetch. Revisa la salida de cmake."
fi
echo "Compilando Fastfetch (la salida de cmake --build será visible)..."
if ! sudo -u "$REAL_USER" cmake --build build --config Release --target fastfetch; then
    handle_error "$log_action" "Error al compilar Fastfetch. Revisa los logs de compilación."
fi
echo "Instalando Fastfetch en /usr/local/bin..."
if ! cp build/fastfetch /usr/local/bin/; then
    handle_error "$log_action" "Error al instalar Fastfetch en /usr/local/bin. Verifica los permisos."
fi
mark_task_completed "$log_action"

# Configurar Powerlevel10k
log_action="Configurar Powerlevel10k para usuario"
echo "Configurando Powerlevel10k para el usuario..."
if [ -d "$user_home/powerlevel10k" ]; then
    echo "El directorio powerlevel10k ya existe para el usuario. Saltando clonación."
else
    echo "Clonando Powerlevel10k para el usuario (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"; then
        handle_error "$log_action" "Error al clonar powerlevel10k para el usuario."
    fi
fi
# Añadir la línea al .zshrc del usuario si no existe
if ! grep -q 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' "$user_home/.zshrc"; then
    echo 'source $HOME/powerlevel10k/powerlevel10k.zsh-theme' | sudo -u "$REAL_USER" tee -a "$user_home/.zshrc" > /dev/null || handle_error "$log_action" "Error al configurar .zshrc para powerlevel10k del usuario."
fi
mark_task_completed "$log_action"

log_action="Configurar Powerlevel10k para root"
echo "Configurando Powerlevel10k para root..."
if [ -d "/root/powerlevel10k" ]; then
    echo "El directorio powerlevel10k ya existe para root. Saltando clonación."
else
    echo "Clonando Powerlevel10k para root (la salida de git será visible en caso de error)..."
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k; then
        handle_error "$log_action" "Error al clonar powerlevel10k para root."
    fi
fi
# Añadir la línea al .zshrc de root si no existe
if ! grep -q 'source /root/powerlevel10k/powerlevel10k.zsh-theme' /root/.zshrc; then
    echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' | tee -a /root/.zshrc > /dev/null || handle_error "$log_action" "Error al configurar .zshrc para powerlevel10k de root."
fi
mark_task_completed "$log_action"

# Copiar .zshrc de usuario y root
log_action="Copiar .zshrc de usuario"
echo "Copiando .zshrc de usuario..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/zshrc/user/.zshrc" "$user_home/.zshrc"; then
    handle_error "$log_action" "Error al copiar .zshrc de usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/zshrc/user/.zshrc' exista."
fi
mark_task_completed "$log_action"

log_action="Ajustar permisos de .zshrc de usuario"
echo "Ajustando permisos de .zshrc de usuario..."
if ! chown "$REAL_USER":"$REAL_USER" "$user_home/.zshrc"; then handle_error "$log_action" "Error al cambiar propietario de .zshrc de usuario."; fi
if ! chmod 644 "$user_home/.zshrc"; then handle_error "$log_action" "Error al cambiar permisos de .zshrc de usuario."; fi
mark_task_completed "$log_action"

log_action="Copiar .zshrc de root"
echo "Copiando .zshrc de root..."
if ! cp "$user_home/Entorno-Linux/Config/zshrc/root/.zshrc" /root/.zshrc; then
    handle_error "$log_action" "Error al copiar .zshrc de root. Asegúrate de que '$user_home/Entorno-Linux/Config/zshrc/root/.zshrc' exista."
fi
if ! chown root:root /root/.zshrc; then handle_error "$log_action" "Error al cambiar propietario de .zshrc de root."; fi
if ! chmod 644 /root/.zshrc; then handle_error "$log_action" "Error al cambiar permisos de .zshrc de root."; fi
mark_task_completed "$log_action"

# Instalar bat y lsd (.deb)
log_action="Copiar archivos de lsd"
echo "Copiando archivos .deb de lsd y bat a Downloads..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/Downloads"; then
    handle_error "$log_action" "No se pudo crear el directorio Downloads para el usuario."
fi
if ! sudo -u "$REAL_USER" cp -a "$user_home/Entorno-Linux/lsd/." "$user_home/Downloads/"; then
    handle_error "$log_action" "Error al copiar archivos de lsd a Downloads. Asegúrate de que '$user_home/Entorno-Linux/lsd/' exista y tenga contenido."
fi
mark_task_completed "$log_action"

log_action="Instalar bat y lsd"
echo "Instalando bat..."
if ! dpkg -i "$user_home/Downloads/bat_0.24.0_amd64.deb" > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de bat (dpkg). Intentando resolver dependencias faltantes." >&2
    if ! apt --fix-broken install -y > /dev/null 2>&1; then # Intenta arreglar dependencias
        echo "Advertencia: Falló la resolución de dependencias para bat. Instalación de bat incompleta." >&2
    fi
fi
echo "Instalando lsd..."
if ! dpkg -i "$user_home/Downloads/lsd_1.1.2_amd64.deb" > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de lsd (dpkg). Intentando resolver dependencias faltantes." >&2
    if ! apt --fix-broken install -y > /dev/null 2>&1; then # Intenta arreglar dependencias
        echo "Advertencia: Falló la resolución de dependencias para lsd. Instalación de lsd incompleta." >&2
    fi
fi
mark_task_completed "$log_action"

# Actualizar .p10k.zsh
log_action="Actualizar .p10k.zsh de usuario"
echo "Copiando .p10k.zsh para el usuario..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh" "$user_home/.p10k.zsh"; then
    handle_error "$log_action" "Error al actualizar .p10k.zsh de usuario. Asegúrate de que '$user_home/Entorno-Linux/Config/Power10kNormal/.p10k.zsh' exista."
fi
mark_task_completed "$log_action"

log_action="Actualizar .p10k.zsh de root"
echo "Copiando .p10k.zsh para root..."
if ! cp "$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh" /root/.p10k.zsh; then
    handle_error "$log_action" "Error al actualizar .p10k.zsh de root. Asegúrate de que '$user_home/Entorno-Linux/Config/Power10kRoot/.p10k.zsh' exista."
fi
mark_task_completed "$log_action"

# Copiar scripts personalizados a bin
log_action="Crear directorio bin en .config"
echo "Creando directorio bin en .config para scripts personalizados..."
if ! sudo -u "$REAL_USER" mkdir -p "$user_home/.config/bin"; then handle_error "$log_action" "Error al crear el directorio bin en .config."; fi
mark_task_completed "$log_action"

log_action="Copiar y dar permisos a scripts personalizados"
echo "Copiando scripts personalizados y asignando permisos de ejecución..."
if ! sudo -u "$REAL_USER" cp "$user_home/Entorno-Linux/bin/"* "$user_home/.config/bin/"; then
    handle_error "$log_action" "Error al copiar scripts personalizados. Asegúrate de que '$user_home/Entorno-Linux/bin/' exista y tenga contenido."
fi

# Dar permisos de ejecución y cambiar la propiedad al usuario
if ! sudo -u "$REAL_USER" chmod +x \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh"; then handle_error "$log_action" "Error al dar permisos de ejecución a scripts personalizados."; fi

# Asegurar que la propiedad sea del usuario para estos scripts específicos
if ! chown "$REAL_USER":"$REAL_USER" \
    "$user_home/.config/bin/ethernet_status.sh" \
    "$user_home/.config/bin/hackthebox_status.sh" \
    "$user_home/.config/bin/target_to_hack.sh"; then
    echo "Advertencia: No se pudo cambiar la propiedad de los scripts en $user_home/.config/bin a $REAL_USER." >&2
fi

mark_task_completed "$log_action"

# Instalar y configurar sudo-plugin
log_action="Crear directorio zsh-sudo-plugin"
echo "Creando directorio para zsh-sudo-plugin en /usr/share/..."
if ! mkdir -p /usr/share/zsh-sudo-plugin; then handle_error "$log_action" "Error al crear directorio zsh-sudo-plugin."; fi
mark_task_completed "$log_action"

log_action="Copiar y configurar sudo.plugin.zsh"
echo "Copiando y configurando sudo.plugin.zsh..."
if ! cp "$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh" /usr/share/zsh-sudo-plugin/; then
    handle_error "$log_action" "Error al copiar sudo.plugin.zsh. Asegúrate de que '$user_home/Entorno-Linux/sudoPlugin/sudo.plugin.zsh' exista."
fi
if ! chmod 755 /usr/share/zsh-sudo-plugin/sudo.plugin.zsh; then handle_error "$log_action" "Error al dar permisos de ejecución a sudo.plugin.zsh."; fi
mark_task_completed "$log_action"

# Instalar npm
log_action="Instalar npm"
echo "Instalando npm..."
if ! apt install -y npm > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de npm." >&2
fi
mark_task_completed "$log_action"

# Instalar Flameshot
log_action="Instalar Flameshot"
echo "Instalando Flameshot..."
if ! apt install -y flameshot > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de Flameshot." >&2
fi
mark_task_completed "$log_action"

# Instalar i3lock
log_action="Instalar i3lock"
echo "Instalando i3lock..."
if ! apt install -y i3lock > /dev/null 2>&1; then
    echo "Advertencia: Falló la instalación de i3lock." >&2
fi
mark_task_completed "$log_action"

# Clonar e instalar i3lock-fancy
log_action="Clonar e instalar i3lock-fancy"
echo "Preparando para clonar e instalar i3lock-fancy..."
cd "$user_home/Downloads" || handle_error "$log_action" "No se pudo cambiar al directorio Downloads ($user_home/Downloads)."

if [ -d "i3lock-fancy" ]; then
    echo "El directorio i3lock-fancy ya existe en Downloads. Saltando clonación."
else
    echo "Clonando i3lock-fancy desde https://github.com/meskarune/i3lock-fancy.git (la salida de git será visible en caso de error)..."
    if ! sudo -u "$REAL_USER" git clone https://github.com/meskarune/i3lock-fancy.git; then
        handle_error "$log_action" "Error al clonar i3lock-fancy. Revisa tu conexión a internet o los permisos."
    fi
fi

cd i3lock-fancy || handle_error "$log_action" "No se pudo cambiar al directorio de i3lock-fancy."
echo "Instalando i3lock-fancy (la salida de make será visible)..."
if ! make install; then
    handle_error "$log_action" "Error al instalar i3lock-fancy."
fi
mark_task_completed "$log_action"

# Crear enlace simbólico batcat
log_action="Crear enlace simbólico batcat"
echo "Creando enlace simbólico para 'batcat' (si es necesario)..."
# Solo crea el enlace si bat existe y el enlace no
if command -v bat &> /dev/null && [ ! -f "/usr/bin/batcat" ]; then
    if ! ln -s /usr/bin/bat /usr/bin/batcat > /dev/null 2>&1; then
        echo "Advertencia: Falló la creación del enlace simbólico para batcat." >&2
    fi
else
    echo "Bat no está instalado o el enlace batcat ya existe. Saltando creación de enlace."
fi
mark_task_completed "$log_action"

# Actualización final del sistema
log_action="Realizar actualización final del sistema"
echo "Realizando 'apt update' final..."
if ! apt update > /dev/null 2>&1; then
    echo "Advertencia: 'apt update' final falló. Esto puede indicar problemas con los repositorios o la red, pero el script ha intentado completar la instalación." >&2
fi

echo "Intentando 'parrot-upgrade' o 'apt upgrade' final..."
if command -v parrot-upgrade &> /dev/null; then
    if ! parrot-upgrade -y > /dev/null 2>&1; then
        echo "Advertencia: 'parrot-upgrade' falló o no está disponible en la actualización final. Intentando 'apt upgrade'." >&2
        if ! apt upgrade -y > /dev/null 2>&1; then
            echo "Advertencia: 'apt upgrade' final también falló. El sistema puede no estar completamente actualizado." >&2
        fi
    fi
else
    echo "Parrot-upgrade no encontrado en la actualización final. Ejecutando 'apt upgrade'."
    if ! apt upgrade -y > /dev/null 2>&1; then
        echo "Advertencia: 'apt upgrade' final también falló. El sistema puede no estar completamente actualizado." >&2
    fi
fi
apt autoremove -y > /dev/null 2>&1 # Limpia paquetes viejos
mark_task_completed "$log_action"

# Mensaje final de entorno listo
log_action="Finalizar y mostrar mensaje de éxito" # Tarea de la checklist

clear_screen # Limpia la pantalla una última vez antes del mensaje final
echo "======================================================"
echo "          ¡EL ENTORNO ESTÁ LISTO!                   "
echo "======================================================"
echo ""
echo "¡Felicidades! La instalación y configuración de tu entorno han finalizado exitosamente."
echo "Para que todos los cambios surtan efecto por completo, te recomendamos encarecidamente"
echo "que **reinicies tu sesión actual** o, idealmente, **reinicies el sistema completo**."
echo ""
read -p "Presiona Enter para finalizar el script y cerrar esta terminal..."

mark_task_completed "$log_action" # Marca la última tarea como completada justo antes de salir

exit 0
