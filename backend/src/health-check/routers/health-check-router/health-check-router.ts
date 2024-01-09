import {Router} from 'express';

class HealthCheckRouter {
  get router() {
    const router = Router();

    router.get('/', (req, res, next) => {
      try {
        return res.json({});
      } catch (err) {
        return next(err);
      }
    });

    return router;
  }
}

export {HealthCheckRouter};
