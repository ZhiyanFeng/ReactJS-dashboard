import express from 'express';
import jwt from 'jsonwebtoken';
import config from '../config';

let route = express.Router();

route.post('/', (req, res) => {

    const { email, password } = req.body;
    var user = {id: 1, username: "daniel",email: "a@b.com", password: 1};

    if (user) {
        if (user.password == password) {
            const token = jwt.sign({
                id: user.id,
                username: user.username
            }, config.jwtSecret);
            res.json({ token });
        } else {
            res.status(4001).json({ errors: { form: 'Invalid Credentials' } });
        }
    } else {
        res.status(4002).json({ errors: { form: 'Invalid Credentials' } });
    }
});

export default route;
