import bunyan from 'bunyan';

export {};

declare global {
  namespace Express {
    export interface Request {
      log: ReturnType<typeof bunyan.createLogger>;
    }
  }
}
