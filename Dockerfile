# Usa una versión estable de Python 3.12 basada en Debian "slim".
FROM python:3.12-slim-bookworm

# Actualiza la lista de paquetes e instala iputils-ping, curl y tzdata (para la zona horaria).
# Luego limpia la caché de apt para reducir el tamaño de la imagen.
RUN apt-get update && \
    apt-get install -y --no-install-recommends iputils-ping curl tzdata && \
    rm -rf /var/lib/apt/lists/*

# Establece la zona horaria del contenedor a GMT-3 (hora de Argentina/Buenos_Aires)
ENV TZ=America/Argentina/Buenos_Aires

# Establece el directorio de trabajo en la raíz del proyecto dentro del contenedor.
# Esto significa que /app será el equivalente a tu carpeta 'dk-panelexemys' local.
WORKDIR /app

# Copia el archivo de dependencias.txt a la raíz del WORKDIR (/app).
COPY dependencias.txt ./
# Instala las dependencias de Python en el entorno global del contenedor.
# Usamos --no-cache-dir para ahorrar espacio.
RUN pip install --no-cache-dir -r ./dependencias.txt

# Copia la carpeta 'src' y el archivo 'config.py' a la raíz del WORKDIR (/app).
# Esto resultará en /app/src y /app/config.py dentro del contenedor.
COPY ./src ./src
COPY config.py ./

# Declara un volumen para la carpeta 'data'.
# Esto le dice a Docker que este directorio contendrá datos que deberían persistir.
# Cuando se monte un volumen externo, este reemplazará el contenido inicial de /app/data.
VOLUME /app/data

EXPOSE 8050

# Define el comando para iniciar la aplicación.
# 'python -m src.app' le dice a Python que ejecute 'app.py' como un módulo
# dentro del paquete 'src'. Como el WORKDIR es /app, Python añade /app al sys.path,
# permitiendo que encuentre tanto 'src' como 'config.py'.
CMD [ "python", "-m", "src.app" ]