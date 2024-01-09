import {Joi} from 'celebrate';
import {NodeEnv} from '../common/enums';

const envVarsSchema = Joi.object()
  .keys({
    LOG_LEVEL: Joi.string().valid('debug', 'info').required(),
    NODE_ENV: Joi.string()
      .valid(NodeEnv.Development, NodeEnv.Test, NodeEnv.Production)
      .required(),
    PORT: Joi.number().integer().required(),
  })
  .unknown();

const {value: envVars, error} = envVarsSchema.validate(process.env);

if (error) {
  throw error;
}

const config = {
  logLevel: envVars.LOG_LEVEL,
  nodeEnv: envVars.NODE_ENV,
  port: envVars.PORT,
};

export {config};
