document.getElementById("btnGenerarPDF").addEventListener("click", function () {
    // Obtener el contenido que queremos convertir a PDF
    var contenido = document.getElementById("boletaPDF");

    // Crear un nuevo objeto jsPDF
    var doc = new jsPDF();

    // Agregar el contenido al PDF
    doc.fromHTML(contenido, 10, 10);

    // Descargar el archivo PDF
    doc.save("mi-boleta-pdf.pdf");
});