require('dotenv').config();
const express = require('express');
const { Sequelize, DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(express.json());
app.use(cors());

// Servir las imágenes subidas de forma pública: http://localhost:3000/uploads/archivo.jpg
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir);
app.use('/uploads', express.static(uploadsDir));

// Configuración de Multer para guardar las fotos de productos en /uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadsDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname) || '.jpg';
        cb(null, `producto_${Date.now()}${ext}`);
    }
});
const upload = multer({ storage });

// Conexión a la base de datos MySQL (genali_shop)
// Las credenciales se leen del archivo backend/.env
const sequelize = new Sequelize(
    process.env.DB_NAME || 'genali_shop',
    process.env.DB_USER || 'root',
    process.env.DB_PASSWORD || '',
    {
        host: process.env.DB_HOST || '127.0.0.1',
        port: Number(process.env.DB_PORT) || 3306,
        dialect: 'mysql',
        logging: false
    }
);

// ============================================================
//  MODELOS
// ============================================================
const User = sequelize.define('User', {
    nombre: { type: DataTypes.STRING, allowNull: false },
    apellido: { type: DataTypes.STRING, allowNull: true },
    correo: { type: DataTypes.STRING, allowNull: false, unique: true },
    contrasena: { type: DataTypes.STRING, allowNull: false }
});

const Product = sequelize.define('Product', {
    nombre: { type: DataTypes.STRING, allowNull: false },
    categoria: { type: DataTypes.STRING, allowNull: false },
    precio: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
    stock: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
    tallas: { type: DataTypes.STRING, allowNull: true },      // "S,M,L"
    imagen: { type: DataTypes.STRING, allowNull: true },      // URL pública de la foto
    descripcion: { type: DataTypes.TEXT, allowNull: true },
    activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
    esFavorito: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false }
});

const Sale = sequelize.define('Sale', {
    producto: { type: DataTypes.STRING, allowNull: false },
    talla: { type: DataTypes.STRING, allowNull: true },
    cantidad: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
    empleado: { type: DataTypes.STRING, allowNull: true }
});

// Sincronizar con la base de datos.
// { alter: true } agrega columnas nuevas a tablas existentes sin borrar datos.
sequelize.sync({ alter: true })
    .then(() => console.log('Base de datos sincronizada correctamente'))
    .catch(err => console.error('Error al sincronizar base de datos:', err));

// Devuelve la URL absoluta de la imagen para que la app la pueda mostrar
function urlImagen(req, nombreArchivo) {
    if (!nombreArchivo) return null;
    if (nombreArchivo.startsWith('http')) return nombreArchivo;
    return `${req.protocol}://${req.get('host')}/uploads/${nombreArchivo}`;
}

function serializarProducto(req, p) {
    return {
        id: p.id,
        nombre: p.nombre,
        categoria: p.categoria,
        precio: p.precio,
        stock: p.stock,
        tallas: p.tallas ? p.tallas.split(',').map(t => t.trim()).filter(t => t) : [],
        imagen: urlImagen(req, p.imagen),
        descripcion: p.descripcion || '',
        activo: p.activo,
        esFavorito: p.esFavorito
    };
}

// ============================================================
//  ENDPOINT RAÍZ (prueba de vida)
// ============================================================
app.get('/', (req, res) => res.json({ ok: true, mensaje: 'Backend Variedades Genali activo' }));

// ============================================================
//  USUARIOS
// ============================================================
app.get('/users', async (req, res) => {
    try {
        const usuarios = await User.findAll({ attributes: ['id', 'nombre', 'apellido', 'correo'] });
        res.json(usuarios);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener los usuarios.' });
    }
});

// Registro de usuario. Acepta /users y /usuarios (alias que usa la app)
async function registrarUsuario(req, res) {
    try {
        const { nombre, apellido, correo, contrasena, password } = req.body;
        const clave = contrasena || password;

        const usuarioExistente = await User.findOne({ where: { correo } });
        if (usuarioExistente) {
            return res.status(400).json({ message: 'El correo electrónico ya se encuentra registrado.' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(clave, salt);

        const nuevoUsuario = await User.create({
            nombre,
            apellido: apellido || 'Genali',
            correo,
            contrasena: hashedPassword
        });

        res.status(201).json({
            message: 'Usuario registrado correctamente.',
            usuario: { id: nuevoUsuario.id, nombre: nuevoUsuario.nombre, correo: nuevoUsuario.correo }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
}
app.post('/users', registrarUsuario);
app.post('/usuarios', registrarUsuario);

// Login
app.post('/usuarios/login', async (req, res) => {
    try {
        const { correo, password, contrasena } = req.body;
        const passwordUser = password || contrasena;

        const usuario = await User.findOne({ where: { correo } });
        if (!usuario) {
            return res.status(400).json({ message: 'Correo o contraseña incorrectos.' });
        }

        const esValida = await bcrypt.compare(passwordUser, usuario.contrasena);
        if (!esValida) {
            return res.status(400).json({ message: 'Correo o contraseña incorrectos.' });
        }

        // Correos con rol de gerente (acceso total). Agrega aquí más si hace falta.
        const GERENTES = ['genesismartniez@gmail.com', 'jr4419543@gmail.com'];
        const rol = (GERENTES.includes(usuario.correo) || usuario.correo.includes('admin')) ? 'gerente' : 'empleado';

        res.status(200).json({
            message: '¡Bienvenido!',
            rol,
            usuario: { id: usuario.id, nombre: usuario.nombre, correo: usuario.correo }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
});

// ============================================================
//  PRODUCTOS
// ============================================================

// Listar productos. Por defecto solo los activos; ?todos=1 devuelve todos.
app.get('/productos', async (req, res) => {
    try {
        const where = req.query.todos === '1' ? {} : { activo: true };
        const productos = await Product.findAll({ where, order: [['createdAt', 'DESC']] });
        res.json(productos.map(p => serializarProducto(req, p)));
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener los productos.' });
    }
});

// Crear producto (con foto opcional en el campo "imagen" de tipo archivo)
app.post('/productos', upload.single('imagen'), async (req, res) => {
    try {
        const { nombre, categoria, precio, stock, tallas, talla, descripcion, activo, esFavorito } = req.body;

        const nuevo = await Product.create({
            nombre,
            categoria,
            precio: parseFloat(precio) || 0,
            stock: parseInt(stock) || 0,
            tallas: tallas || talla || '',
            descripcion: descripcion || '',
            activo: activo === undefined ? true : (activo === 'true' || activo === true),
            imagen: req.file ? req.file.filename : null,
            esFavorito: esFavorito === 'true' || esFavorito === true
        });

        res.status(201).json({
            message: 'Producto guardado correctamente.',
            producto: serializarProducto(req, nuevo)
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al guardar el producto.' });
    }
});

// Actualizar producto (foto opcional)
app.put('/productos/:id', upload.single('imagen'), async (req, res) => {
    try {
        const producto = await Product.findByPk(req.params.id);
        if (!producto) return res.status(404).json({ message: 'Producto no encontrado.' });

        const { nombre, categoria, precio, stock, tallas, talla, descripcion, activo, esFavorito } = req.body;
        if (nombre !== undefined) producto.nombre = nombre;
        if (categoria !== undefined) producto.categoria = categoria;
        if (precio !== undefined) producto.precio = parseFloat(precio) || 0;
        if (stock !== undefined) producto.stock = parseInt(stock) || 0;
        if (tallas !== undefined || talla !== undefined) producto.tallas = tallas || talla || '';
        if (descripcion !== undefined) producto.descripcion = descripcion;
        if (activo !== undefined) producto.activo = activo === 'true' || activo === true;
        if (esFavorito !== undefined) producto.esFavorito = esFavorito === 'true' || esFavorito === true;
        if (req.file) producto.imagen = req.file.filename;

        await producto.save();
        res.json({ message: 'Producto actualizado.', producto: serializarProducto(req, producto) });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar el producto.' });
    }
});

// Eliminar producto
app.delete('/productos/:id', async (req, res) => {
    try {
        const producto = await Product.findByPk(req.params.id);
        if (!producto) return res.status(404).json({ message: 'Producto no encontrado.' });
        await producto.destroy();
        res.json({ message: 'Producto eliminado.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar el producto.' });
    }
});

// ============================================================
//  VENTAS (registra la venta y descuenta stock real)
// ============================================================
app.post('/ventas', async (req, res) => {
    try {
        const { productoId, producto, talla, cantidad, empleado } = req.body;
        const cant = parseInt(cantidad) || 1;

        // Buscar el producto por id o por nombre para descontar stock
        let prod = null;
        if (productoId) prod = await Product.findByPk(productoId);
        if (!prod && producto) prod = await Product.findOne({ where: { nombre: producto } });

        if (prod) {
            prod.stock = Math.max(0, prod.stock - cant);
            await prod.save();
        }

        const venta = await Sale.create({
            producto: producto || (prod ? prod.nombre : 'Desconocido'),
            talla: talla || null,
            cantidad: cant,
            empleado: empleado || null
        });

        res.status(201).json({
            message: 'Venta registrada correctamente.',
            venta,
            stockRestante: prod ? prod.stock : null
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al registrar la venta.' });
    }
});

// Listar ventas
app.get('/ventas', async (req, res) => {
    try {
        const ventas = await Sale.findAll({ order: [['createdAt', 'DESC']] });
        res.json(ventas);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener las ventas.' });
    }
});

// ============================================================
//  INICIAR SERVIDOR
// ============================================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend corriendo en http://0.0.0.0:${PORT}`);
});
