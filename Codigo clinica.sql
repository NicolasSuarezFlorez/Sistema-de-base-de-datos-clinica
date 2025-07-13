USE clinica_citas;

CREATE TABLE especialidad (
    id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    descripcion TEXT
);

CREATE TABLE medico (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(50),
    apellidos VARCHAR(50),
    id_especialidad INT,
    consultorio VARCHAR(10),
    horario VARCHAR(100),
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

CREATE TABLE paciente (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(50),
    apellidos VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    fecha_nacimiento DATE
);

CREATE TABLE servicio (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    nombre_servicio VARCHAR(100),
    costo DECIMAL(10, 2)
);


CREATE TABLE cita (
    id_cita INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    id_medico INT,
    id_servicio INT, -- Nueva FK para el servicio
    fecha_cita DATE,
    hora_cita TIME,
    estado VARCHAR(20),
    costo_calculado DECIMAL(10, 2), -- Columna para almacenar el costo de la cita
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
);

CREATE TABLE factura (
    id_factura INT PRIMARY KEY AUTO_INCREMENT,
    id_cita INT, -- FK a la cita que genera la factura
    fecha_emision DATE,
    total_factura DECIMAL(10, 2),
    estado_pago VARCHAR(20), -- (ej. 'Pendiente', 'Pagada', 'Anulada')
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
);
INSERT INTO especialidad (nombre, descripcion) VALUES
('Cardiología', 'Especialidad médica que se encarga del diagnóstico y tratamiento de las enfermedades del corazón.'),
('Pediatría', 'Atención médica de niños y adolescentes.'),
('Dermatología', 'Tratamiento de enfermedades de la piel.');

INSERT INTO medico (nombres, apellidos, id_especialidad, consultorio, horario) VALUES
('Juan', 'Pérez', 1, 'C101', 'Lunes a Viernes 08:00-12:00'),
('María', 'González', 2, 'C102', 'Lunes a Viernes 13:00-17:00'),
('Carlos', 'Ramírez', 3, 'C103', 'Martes y Jueves 09:00-15:00');

INSERT INTO paciente (nombres, apellidos, telefono, correo, fecha_nacimiento) VALUES
('Luis', 'Martínez', '3123456789', 'luis.martinez@mail.com', '1990-05-20'),
('Ana', 'Rodríguez', '3112345678', 'ana.rodriguez@mail.com', '1985-08-15'),
('Pedro', 'Sánchez', '3109876543', 'pedro.sanchez@mail.com', '2000-02-10');


INSERT INTO servicio (nombre_servicio, costo) VALUES
('Consulta General', 50000.00),
('Electrocardiograma', 80000.00),
('Evaluación Dermatológica', 70000.00);


INSERT INTO cita (id_paciente, id_medico, id_servicio, fecha_cita, hora_cita, estado, costo_calculado) VALUES
(1, 1, 2, '2025-07-15', '09:00:00', 'Agendada', 80000.00),
(2, 2, 1, '2025-07-16', '10:30:00', 'Confirmada', 50000.00),
(3, 3, 3, '2025-07-17', '14:00:00', 'Agendada', 70000.00);


INSERT INTO factura (id_cita, fecha_emision, total_factura, estado_pago) VALUES
(1, '2025-07-15', 80000.00, 'Pendiente'),
(2, '2025-07-16', 50000.00, 'Pagada'),
(3, '2025-07-17', 70000.00, 'Anulada');


-- vista para ver la información las citas con la informacion de paciente, medico, especialidad, etc..
use clinica_citas;
CREATE OR REPLACE VIEW vista_detalle_citas AS
SELECT 
    c.id_cita,
    CONCAT(p.nombres, ' ', p.apellidos) AS nombre_paciente,
    CONCAT(m.nombres, ' ', m.apellidos) AS nombre_medico,
    e.nombre AS especialidad,
    s.nombre_servicio,
    c.fecha_cita,
    c.hora_cita,
    c.estado,
    c.costo_calculado
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN medico m ON c.id_medico = m.id_medico
JOIN especialidad e ON m.id_especialidad = e.id_especialidad
JOIN servicio s ON c.id_servicio = s.id_servicio;
SELECT * FROM clinica_citas.vista_detalle_citas;

-- Ver medico por especilidad y horario de atención

SELECT 
    e.nombre AS especialidad,
    m.nombres AS nombre_medico,
    m.apellidos AS apellido_medico,
    m.consultorio,
    m.horario
FROM 
    medico m
JOIN especialidad e ON m.id_especialidad = e.id_especialidad
ORDER BY 
    e.nombre, m.apellidos;


-- Procedimiento de almacenado para traer la informacion de una cita segun su fecha

DELIMITER //

CREATE PROCEDURE GetCitasPorFecha(
    IN p_fecha DATE
)
BEGIN
    SELECT 
        c.id_cita,
        p.nombres AS nombre_paciente,
        p.apellidos AS apellido_paciente,
        m.nombres AS nombre_medico,
        m.apellidos AS apellido_medico,
        s.nombre_servicio,
        c.hora_cita,
        c.estado
    FROM 
        cita c
    JOIN paciente p ON c.id_paciente = p.id_paciente
    JOIN medico m ON c.id_medico = m.id_medico
    JOIN servicio s ON c.id_servicio = s.id_servicio
    WHERE 
        c.fecha_cita = p_fecha
    ORDER BY 
        c.hora_cita;
END //

DELIMITER ;
CALL GetCitasPorFecha('2025-07-15');