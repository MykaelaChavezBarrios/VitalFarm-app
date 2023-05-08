from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL
import mysql.connector

app = Flask(__name__)


def connect():
    mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        password="clavenueva",
        database="dbfacturacion",
    )
    return mydb


@app.route("/")
def index():
    mydb = connect()
    cur = mydb.cursor()
    cur.execute("CALL ver_sucursales()")
    sucursales = cur.fetchall()
    cur.close()
    mydb.close()
    return render_template("sedeInicio.html", sucursales=sucursales)


@app.route("/sucursal/<int:id>")
def menu(id):
    mydb = connect()
    cur = mydb.cursor()
    cur.execute("CALL ver_sucursal(%s)", (id,))
    sucursal = cur.fetchone()
    cur.close()
    mydb.close()
    return render_template("inicio.html", sucursal=sucursal)


@app.route("/sucursal/<int:id>/medicamentos")
def medicamentos(id):
    mydb = connect()
    cur = mydb.cursor()
    cur.execute("CALL ver_inventario(%s)", (id,))
    medicamentos = cur.fetchall()
    cur.close()
    mydb.close()
    return render_template("medicamentos.html", medicamentos=medicamentos)


@app.route("/nuevaBoleta")
def nuevaBoleta():
    return render_template("nuevaboleta.html")


@app.route("/sucursal/<int:id>/historial")
def historial(id):
    mydb = connect()
    cur = mydb.cursor()
    cur.execute("CALL ver_historial(%s)", (id,))
    facturas = cur.fetchall()
    cur.close()
    mydb.close()
    return render_template("historial.html", facturas=facturas)


@app.route("/boletaExtendida")
def boletaExtendida():
    return render_template("boletaExtendida.html")


@app.route("/agregarProducto")
def agregarProducto():
    return render_template("agregarproducto.html")


if __name__ == "__main__":
    app.run(debug=True)
