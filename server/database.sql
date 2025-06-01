USE comedor;

-- Tabla Rol
CREATE TABLE Rol (
    PK_ROL INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Admin
CREATE TABLE Admin (
    ID_Admin INT PRIMARY KEY,
    Usuario VARCHAR(50) NOT NULL,
    Contrasena VARCHAR(50) NOT NULL,
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(PK_ROL)
);

CREATE TABLE Chef (
    correo VARCHAR(60) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoP VARCHAR(50) NOT NULL,
    ApellidoM VARCHAR(50) NOT NULL,
    Contrasena VARCHAR(50) NOT NULL,
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(PK_ROL)
);

-- Tabla Estudiante
CREATE TABLE Estudiante (
    ID_No_Control VARCHAR(20) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoP VARCHAR(50) NOT NULL,
    ApellidoM VARCHAR(50) NOT NULL,
    Correo VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Contrasena VARCHAR(50) NOT NULL,
    Carrera VARCHAR(50) NOT NULL,
    Semestre INT NOT NULL,
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(PK_ROL)
);

-- Tabla Docente
CREATE TABLE Docente (
    ID_RFC VARCHAR(20) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoP VARCHAR(50) NOT NULL,
    ApellidoM VARCHAR(50) NOT NULL,
    Correo VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Contrasena VARCHAR(50) NOT NULL,
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(PK_ROL)
);

-- Insertar roles
INSERT INTO Rol (PK_ROL, Nombre) VALUES
(1, 'Administrador'),
(2, 'Chef'),
(3, 'Estudiante'),
(4, 'Docente');

-- Insertar admin por defecto
INSERT INTO Admin (ID_Admin, Usuario, Contrasena, PK_ROL) VALUES
(1, 'admin', 'admin123', 1); 