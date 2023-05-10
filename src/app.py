from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL
import mysql.connector
import datetime

app = Flask(__name__)
app.secret_key = "VitalFarm1234"


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


@app.route("/sucursal/<int:id>/agregarproducto/<int:codfact>")
def agregarProducto(id, codfact):
    description = request.args.get("description")
    cantidad = request.form.get("cantidad")
    if description:
        mydb = connect()
        cur = mydb.cursor()
        cur.execute("call buscar_med(%s,%s)", (description, id))
        tabla = cur.fetchall()
        for producto in tabla:
            query = "call addMed(%s,%s,%s)"
            cur.execute(query, (codfact, producto[0], cantidad))
        mydb.commit()
        cur.close()
        mydb.close()
        return redirect(url_for("verProductos", id=id, codfact=codfact))
    return render_template("agregarproducto.html")


@app.route("/sucursal/<int:id>/factura/<int:codfact>/productos")
def verProductos(id, codfact):
    mydb = connect()
    cur = mydb.cursor()
    query = "call factDetalle(%s)"
    cur.execute(query, (codfact,))
    productos = cur.fetchall()
    return render_template("productos_agregados.html", productos=productos)


@app.route("/sucursal/<int:id>/nuevaBoleta", methods=["GET", "POST"])
def nuevaBoleta(id):
    if request.method == "POST":
        fecha = datetime.datetime.strptime(request.form["fecha"], "%Y-%m-%d").date()
        dni = request.form["dni"]
        cliente = request.form["cliente"]
        print(f"dni: {dni}, cliente: {cliente}, id: {id}")
        mydb = connect()
        if mydb.is_connected():
            print("Conexión exitosa a la base de datos")
        else:
            print("No se pudo conectar a la base de datos")
        cur = mydb.cursor()
        query = "INSERT INTO trFactura(codS, fecha, dni, nombre, igv, total) VALUES (%s, %s, %s, %s, 0, 0)"
        values = (id, fecha, dni, cliente)
        cur.execute(query, values)
        mydb.commit()
        cur.close()
        mydb.close()
        mydb = connect()
        cur_2 = mydb.cursor()
        query2 = "SELECT codF from trFactura WHERE codS = %s"
        cur_2.execute(query2, [id])
        codigos = cur_2.fetchall()
        print(codigos)
        codfact = codigos[-1][0]
        print(codfact)
        cur.close()
        mydb.close()
        return redirect(url_for("agregarProducto", id=id, codfact=codfact))
    return render_template("nuevaboleta.html")


if __name__ == "__main__":
    app.run(debug=True)
