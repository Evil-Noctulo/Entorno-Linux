
# Entorno de S4vitar en Kali Linux 100% Funcional

![image](https://github.com/user-attachments/assets/aefbc484-a87c-4fc2-906a-b7e77bccc18e)

Bienvenidos a la guía de personalización del entorno de S4vitar en Kali Linux. Aquí encontrarás todos los pasos necesarios para una instalación completa y funcional.

## Video Tutorial

Puedes seguir el video tutorial paso a paso en mi [canal de YouTube](https://www.youtube.com/@CristianSinH-Ciber). Si el contenido es de tu agrado, considera suscribirte y seguirme en [LinkedIn](https://www.linkedin.com/in/cristian-hsilva).
Recuerda que este script esta diseñado para un sistema operavito Kali Linux en Ingles, si lo quieres en español, cambia en el install.sh Downloads por Descargas. 

## Instalación

Clona el repositorio y prepara la instalación con los siguientes comandos:

```bash
git clone https://github.com/Balthael/KaliEntorno
cd KaliEntorno
chmod +x install.sh
sudo ./install.sh
```

Después de la instalación, asegúrate de seleccionar BSPWM e instalar `fzf` y `nvim`, ya que no están incluidos en el script inicial.

 ![bspwm](images/02.png)

### Problemas comunes

Si encuentras un error al cambiar al usuario root, sigue estos pasos para corregirlo:

![Error root](images/03.png)

Solución:

```bash
Ctrl + C
compaudit
chown root:root /usr/local/share/zsh/site-functions/_bspc
exit
```

![Solución error](images/04.png)

### Instalación de fzf

Instalación para usuarios root y no privilegiados:

**Root:**

```bash
sudo su
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

**Usuario no privilegiado:**

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Instalación de Neovim

#### Para Root:

```bash
sudo su
cd
git clone https://github.com/NvChad/starter ~/.config/nvim
mkdir /opt/nvim
cd /opt/nvim
mv /home/su_usuario/KaliEntorno/neovim/nvim-linux64 .
cd /opt/nvim/nvim-linux64/bin
./nvim
```

#### Para Usuario No Privilegiado:

```bash
cd
git clone https://github.com/NvChad/starter ~/.config/nvim
nvim
```

####
# Rutas

Polybar

`~/.config/polybar`

bspwn

`~/.config/bspwm`

sxhkd (short cut)

`~/.config/sxhkd`

Picom

`~/.config/picom`

# Problemas con nvim

Puede que al usar nvim se dupliquen caracterres como al apretar tab o backspace para debemos hacer lo siguiente

✅ Borra el actual:

`sudo rm -rf /opt/nvim/`

📦 Descarga la última versión estable oficial de Neovim:

https://github.com/neovim/neovim/releases/tag/v0.11.1

![image.png](attachment:a7568177-ba01-4bb4-b60a-8fed564ab644:image.png)

descomprimimos

`tar -xf nvim-linux64.tar.gz`

🚀 Instala y enlaza:

`sudo mv nvim-linux64 /opt/nvim`
`sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim`

# Instalar nvchad

ingresar a la pagina hacer los pasos anterior

https://nvchad.com/docs/quickstart/install/

`git clone https://github.com/NvChad/starter ~/.config/nvim && nvim` 

y listo

## Otro problema con nvim

puede que al usar nvim tengamos este error

```jsx
Error detected while processing /home/noctulo/.config/nvim/init.lua:
E5113: Error while calling lua chunk: /home/noctulo/.config/nvim/init.lua:7: attempt to index field 'uv' (a nil value)
stack traceback:
/home/noctulo/.config/nvim/init.lua:7: in main chunk
```

**Correción de Nvim**

actualizar kitty, nuevamente pero ahora de forma manual

`curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh`

```bash
sudo su # usar estos comandos de forma individual
cd # usar estos comandos de forma individual

git clone https://github.com/NvChad/starter ~/.config/nvim
mkdir /opt/nvim
cd /opt/nvim
mv /home/sinh/Entorno-Linux/neovim/nvim-linux64 .
cd /opt/nvim/nvim-linux64/bin
./nvim
```

Ahora con el usuario normal

```bash
cd # usar estos comandos de forma individual
git clone https://github.com/NvChad/starter ~/.config/nvim
nvim
```

ahora debemos crear un alias. LO hacemos como root y usuario no privilegiado

```bash
echo 'alias nvim="/opt/nvim/nvim-linux64/bin/nvim"' >> ~/.zshrc
source ~/.zshrc
```

Si el error persiste hacer lo siguiente:

`sudo rm /usr/bin/kitty`

```bash
sudo tee /usr/local/bin/kitty > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /home/sinh/.local/kitty.app/bin/kitty "$@"
EOF
sudo chmod +x /usr/local/bin/kitty
```

Modificar sxhkdrc

`sudo nvim ~/.config/sxhkd/sxhkdrc`

`/home/sinh/.local/kitty.app/bin/kitty`

`pkill -USR1 -x sxhkd`

en caso de tener error al usar `sudo nvim` hacer lo siguiente

`sudo rm -f /usr/local/bin/nvim` 

`sudo ln -s /opt/nvim/nvim-linux64/bin/nvim /usr/local/bin/nvim`

Cargar zsh en root

`sudo chsh -s /usr/bin/zsh root`

modificar target

`sudo chown usuario:usuario /home/usuario/.config/bin/target`

configurar p10k

`p10k configure`


Atajos (Personalización de entorno en Linux)

| Combinación           | Acción                                   |
| --------------------- | ---------------------------------------- |
| `Windows + Enter`     | Abrir Terminal                           |
| `Windows + Q`         | Cerrar Terminal                          |
| `Windows + D`         | Abrir Rofi                               |
| `Windows + Esc`       | 'Aplicar' la configuración               |
| `Windows + Shift + R` | Recargar Entorno                         |
| `Windows + Shift + Q` | Volver a la pantalla de bloqueo          |
| `Esc + Esc`           | Sudo                                     |
| `Ctrl + Alt + Mouse`  | Seleccionar copiar/pegar en modo Columna |
| `Windows + Shift + X` | Bloquear Entorno                         |

#### 🔹 Polybar

|Combinación|Acción|
|---|---|
|`Windows + 1 - 0`|Desplazamiento por ventanas|
|`Windows + Shift + 1 - 0`|Enviar el proceso actual a otra ventana de trabajo|

#### 🔹 Preselectores

|Combinación|Acción|
|---|---|
|`Windows + Ctrl + Alt + Flechas`|Abrir Preselector|
|`Windows + Ctrl + Alt + Espacio`|Cerrar Preselector|
|`Windows + Ctrl + 1 - 0`|Cambiar tamaño del Preselector|
|`Windows + Ctrl + M`|Seleccionar proceso y enviarlo a un Preselector nuevo|
|`Windows + Y`|Aplicar proceso previamente seleccionado|

#### 🔹 Terminal

|Combinación|Acción|
|---|---|
|`Windows + S`|Ejecutar Terminal de forma Ventana Flotante (Screen Floating)|
|`Windows + F`|Ejecutar Terminal de forma Pantalla Completa (Full Screen)|
|`Windows + T`|Ejecutar Terminal de forma Encajada (Terminal)|
|`Windows + Click Izquierdo`|Mover la ventana flotante (Mouse)|
|`Windows + Click Derecho`|Ampliar o reducir el tamaño de la ventana (Mouse)|
|`Windows + Ctrl`|Mover ventana flotante (Atajo)|
|`Windows + Alt`|Ampliar o reducir el tamaño de la ventana (Atajo)|
|`Windows + Shift + Flechas`|Intercambiar terminal de Izquierda/Derecha/Arriba/Abajo|

#### 🔹 Kitty

|Combinación|Acción|
|---|---|
|`Ctrl + Shift + Enter`|Abrir terminal o múltiples|
|`Ctrl + Shift + W`|Cerrar terminal|
|`Ctrl + Shift + R`|Ampliar o reducir tamaño de la terminal (T=Arriba S=Abajo)|
|`Ctrl + Shift + T + número`|Nueva pestaña/etiqueta|
|`Ctrl + Shift + Alt + T`|Renombrar|
|`Ctrl + Shift + Alt + , / .`|Desplazamiento por pestañas (Signo coma o punto)|

#### 🔹 FZF

|Combinación|Acción|
|---|---|
|`Ctrl + R`|Buscar por el Historial (utiliza Flechas para desplazarte)|
|`wh Ctrl + T`|Te mueves por lo que hayas escrito anteriormente (`escribes wh`)|
|`cd ** Ctrl + T`|Buscar directorios (`escribes cd**`)|
|`rm Ctrl + T`|Seleccionas con TAB archivos a eliminar y con ENTER aceptas (`escribes rm`)|

---

## Contacto

Si tienes preguntas o necesitas ayuda, no dudes en escribirme a mi [LinkedIn](https://www.linkedin.com/in/cristian-hsilva).

Gracias

