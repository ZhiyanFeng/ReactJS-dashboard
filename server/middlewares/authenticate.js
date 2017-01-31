import jwt from 'jsonwebtoken';
import config from '../config';

export default (req, res, next) => {
    const authorizationHeader = req.headers['authorization'];
    let token;

    console.log('i am in-------------------');
    if (authorizationHeader) {
        token = authorizationHeader.split(' ')[1];
    console.log('i am in-------------------', token);
    }

    if (token) {
        jwt.verify(token, config.jwtSecret, (err, decoded) => {
    console.log('i am in---if(token)', token);

            if (err) {
                res.status(401).json({ error: 'Failed to authenticate' });
            }     });
    } else {
        res.status(403).json({
            error: 'No token provided'
        });
    }
}
