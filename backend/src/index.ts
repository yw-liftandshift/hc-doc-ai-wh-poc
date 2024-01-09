import {createApp} from './app';
import {config} from './config';

createApp().then(({app, logger}) => {
  app.listen(config.port, () => {
    logger.info(
      `Health Canada - DocAI Warehouse POC - Backend listening on port ${config.port}...`
    );
  });
});
