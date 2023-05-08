from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL
import mysql.connector

app = Flask(__name__)

mydb = mysql.connector.connect(
    host="localhost", user="root", password="clavenueva", database="dbfacturacion"
)


@app.route("/")
def index():
    cur = mydb.cursor()
    cur.execute("CALL ver_sucursales()")
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
