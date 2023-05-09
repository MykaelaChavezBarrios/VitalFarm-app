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
    sucursal = [id]
    cur.close()
    mydb.close()
    return render_template(
        "medicamentos.html", medicamentos=medicamentos, sucursal=sucursal
    )


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


@app.route("/boleta_extendida/<int:id_boleta>")
def boletaExtendida(id_boleta):
    mydb = connect()
    cur_cab = mydb.cursor()
    cur_cab.execute("CALL factCabecera(%s)", (id_boleta,))
    boletaC = cur_cab.fetchone()
    cur_cab.close()
    mydb.close()
    mydb.connect()
    cur_det = mydb.cursor()
    cur_det.execute("CALL factDetalle(%s)", (id_boleta,))
    boletaD = cur_det.fetchall()
    cur_det.close()
    mydb.close()
    return render_template("boletaExtendida.html", boletaC=boletaC, boletaD=boletaD)


@app.route("/agregarProducto")
def agregarProducto():
    return render_template("agregarproducto.html")


if __name__ == "__main__":
    app.run(debug=True)
