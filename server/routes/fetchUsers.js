import express from 'express';
import authenticate from '../middlewares/authenticate';

let router = express.Router();

router.post('/', authenticate, (req, res) => {
    console.log('i am in-------------------');
      res.status(201).json({ success: true  });
});

export default router;
