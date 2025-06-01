const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());


const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',      
  password: '567890',      
  database: 'comedor'
});


db.connect((err) => {
  if (err) {
    console.error('Error conectando a MySQL:', err);
    return;
  }
  console.log('Conectado a MySQL');
});

// Rutas para usuarios
app.get('/api/usuarios/:rol', (req, res) => {
  const rol = req.params.rol;
  db.query(`SELECT * FROM ${rol}`, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(results);
  });
});

app.post('/api/usuarios/:rol', (req, res) => {
  const rol = req.params.rol;
  const userData = req.body;
  
  let query = '';
  let values = [];

  switch (rol) {
    case 'Estudiante':
      query = 'INSERT INTO Estudiante (ID_No_Control, Nombre, ApellidoP, ApellidoM, Correo, Telefono, Contrasena, Carrera, Semestre, PK_ROL) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 3)';
      values = [
        userData.matricula,
        userData.Nombre,
        userData.ApellidoPaterno,
        userData.ApellidoMaterno,
        userData.Correo,
        userData.Telefono,
        userData.Contrasena,
        userData.Carrera,
        userData.Semestre
      ];
      break;
    case 'Docente':
      query = 'INSERT INTO Docente (ID_RFC, Nombre, ApellidoP, ApellidoM, Correo, Telefono, Contrasena, PK_ROL) VALUES (?, ?, ?, ?, ?, ?, ?, 4)';
      values = [
        userData.RFC,
        userData.Nombre,
        userData.ApellidoPaterno,
        userData.ApellidoMaterno,
        userData.Correo,
        userData.Telefono,
        userData.Contrasena
      ];
      break;
    case 'Chef':
      query = 'INSERT INTO Chef (correo, Nombre, ApellidoP, ApellidoM, Contrasena, PK_ROL) VALUES (?, ?, ?, ?, ?, 2)';
      values = [
        Date.now(),
        userData.Nombre,
        userData.ApellidoPaterno,
        userData.ApellidoMaterno,
        userData.Contrasena
      ];
      break;
  }

  db.query(query, values, (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ success: true, id: result.insertId });
  });
});

app.post('/api/login', (req, res) => {
  const { identificador, contrasena, rol } = req.body;
  
  const query = `SELECT * FROM ${rol} WHERE ${rol === 'Admin' ? 'Usuario' : 'Correo'} = ? AND Contrasena = ?`;
  
  db.query(query, [identificador, contrasena], (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (results.length > 0) {
      res.json(results[0]);
    } else {
      res.status(401).json({ error: 'Credenciales incorrectas' });
    }
  });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
}); 