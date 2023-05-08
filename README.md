# Farmacia "Vital Farm"

## Autores: "Amado Durand Leonardo Jesús", "Canaza Vargas Mikhael Denzel", "Chávez Barrios Tatyana Mykaela", "Mendoza Polanco Diego Alberto", "Soto Sana Nicoll Stheffany"

## Introducción

Para hacer uso de la API de manera local es necesario realizar los siguientes pasos:

1. Ingresar los siguiente comandos en consola:

```python
python3 -m venv env
```

este comando les creara un entorno virtual para para poder importar posteriormente los paquetes ahi.
Para activarlo se emplea el siguiente comando:

```python
env\Scripts\activate
```

y para apagarlo:

```python
deactivate
```

2. después correr el comando:

```python
pip install -r requirements.txt

pip install flask-mysqldb
```

para obtener los paquetes empleados

3. MYSQL

en al archivo app.py se tiene lo siguiente

```python
app.config["MYSQL_HOST"] = "localhost"
app.config["MYSQL_USER"] = "root"
app.config["MYSQL_PASSWORD"] = "clavenueva"
app.config["MYSQL_DB"] = "dbfacturacion"
```

en un servidor de mysql ejecutar el archivo NewCreateDB.sql
cambie la clave por la clave de su servidor, si no funciona ejecute el siguiente comando

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'clavenueva';
```

4. Para ejecutar la app

```python
python src/app.py run
```

Instalar mysql

```python
sudo apt mysql-server
```

Ejecutar para crear el contenedor

```python
docker run --name "NOMBRE CONTENEDOR" -e MYSQL_ROOT_PASSWORD="CONTRASEÑA" -d -p "PUERTO" mysql
```
