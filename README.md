# HTB-Machine-Finder
Script en Bash para buscar información de máquinas de Hack The Box. Permite buscar por nombre, IP, dificultad, sistema operativo y skills, además de mostrar enlaces a tutoriales de YouTube. Útil para practicar pentesting con CTFs.

## 🚩 Funcionalidades
- Buscar máquinas por nombre, dirección IP, dificultad, sistema operativo o skills
- Obtener enlace directo a tutoriales de YouTube
- Salida colorizada y organizada
- Panel de ayuda para ver opciones disponibles

## 📥 Descarga
```bash
git clone https://github.com/PGantus/HTB-Machine-Finder.git
chmod +x machines.sh
```

## 📌 Uso
```bash 
./machines.sh 
              -u  Descargar o actualizar archivos necesarios
              -m  Buscar por nombre de máquina
              -i  Buscar por dirección IP
              -d  Buscar por difucultad (Fácil, Media, Difícil, Insane)
              -o  Buscar por sistema operativo
              -s  Buscar por skills
              -y  Obtener link de la resolución de la máquina en Youtube
              -h  Mostrar este panel de ayuda
```
