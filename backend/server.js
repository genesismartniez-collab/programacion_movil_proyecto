const express = require('express');
const { Sequelize, DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Conexión a la base de datos MySQL oficial (genali_shop) 
const sequelize = new Sequelize('genali_shop', 'root', 'BTSlola12', {
    host: '127.0.0.1',
    port: 3307,
    dialect: 'mysql',
    logging: false
});

// Definir el Modelo de Usuario
const User = sequelize.define('User', {
    nombre: { type: DataTypes.STRING, allowNull: false },
    apellido: { type: DataTypes.STRING, allowNull: false },
    correo: { type: DataTypes.STRING, allowNull: false, unique: true },
    contrasena: { type: DataTypes.STRING, allowNull: false }
});

// Sincronizar con la base de datos
sequelize.sync()
    .then(() => console.log('Base de datos sincronizada correctamente'))
    .catch(err => console.error('Error al sincronizar base de datos:', err));

// ENDPOINT DE LISTAR USUARIOS (GET /users)
app.get('/users', async (req, res) => {
    try {
        const usuarios = await User.findAll({
            attributes: ['id', 'nombre', 'apellido', 'correo']
        });
        res.json(usuarios);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener los usuarios.' });
    }
});

// ENDPOINT DE REGISTRO (POST /users)
app.post('/users', async (req, res) => {
    try {
        const { nombre, apellido, correo, contrasena } = req.body;

        const usuarioExistente = await User.findOne({ where: { correo } });
        if (usuarioExistente) {
            return res.status(400).json({ 
                error: 'El correo electrónico ya se encuentra registrado.' 
            });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(contrasena, salt);

        const nuevoUsuario = await User.create({
            nombre,
            apellido,
            correo,
            contrasena: hashedPassword
        });

        res.status(201).json({
            mensaje: 'Usuario registrado correctamente.',
            usuario: {
                id: nuevoUsuario.id,
                nombre: nuevoUsuario.nombre,
                correo: nuevoUsuario.correo
            }
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
});

// Iniciar servidor configurado para red local / emulador
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend corriendo en http://0.0.0.0:${PORT}`);
});