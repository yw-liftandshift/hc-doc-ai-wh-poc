import express from 'express';
import * as lb from '@google-cloud/logging-bunyan';
import {HealthCheckRouter} from './health-check';
import {errorHandler} from './error-handler';
import {config} from './config';

async function createApp() {
  const {logger, mw: loggingMiddleware} = await lb.express.middleware({
    level: config.logLevel,
    redirectToStdout: true,
    skipParentEntryForCloudRun: true,
  });

  const healthCheckRouter = new HealthCheckRouter().router;

  const app = express();

  app.use(loggingMiddleware);

  app.use(express.json());

  app.use('/healthz', healthCheckRouter);

  app.use(
    async (
      err: Error,
      req: express.Request,
      res: express.Response,
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      _next: express.NextFunction
    ) => {
      await errorHandler.handleError(err, req, res);
    }
  );

  return {app, logger};
}

export {createApp};
