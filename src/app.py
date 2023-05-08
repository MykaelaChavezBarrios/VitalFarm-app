from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL
import MySQLdb.cursors

app = Flask(__name__)

app.config["MYSQL_HOST"] = "localhost"
app.config["MYSQL_USER"] = "root"
app.config["MYSQL_PASSWORD"] = "clavenueva"
app.config["MYSQL_DB"] = "dbfacturacion"
mysql = MySQL(app)


@app.route("/")
def index():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM maesuc")
    sucursales = cur.fetchall()
    cur.close()
    return render_template("sedeInicio.html", sucursales=sucursales)


@app.route("/menu")
def menu():
    return render_template("inicio.html")


@app.route("/medicamentos")
def medicamentos():
    return render_template("medicamentos.html")


@app.route("/nuevaBoleta")
def nuevaBoleta():
    return render_template("nuevaboleta.html")


@app.route("/historial")
def historial():
    return render_template("historial.html")


@app.route("/boletaExtendida")
def boletaExtendida():
    return render_template("boletaExtendida.html")


@app.route("/agregarProducto")
def agregarProducto():
    return render_template("agregarproducto.html")


if __name__ == "__main__":
    app.run(debug=True)
