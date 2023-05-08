from flask import Flask, render_template
from flask_cors import CORS

app = Flask(__name__)
CORS(app=app)


@app.route("/")
def index():
    return render_template("sedeInicio.html")


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
