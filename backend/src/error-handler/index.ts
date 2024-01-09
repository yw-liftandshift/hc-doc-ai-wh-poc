import {Request, Response} from 'express';
import {isCelebrateError} from 'celebrate';
import {StatusCodes} from 'http-status-codes';
import {
  AlreadyExistsError,
  ForbiddenError,
  NotFoundError,
  UnauthorizedError,
} from '../common/errors';

enum ErrorResponseCode {
  alreadyExists = 'alreadyExists',
  forbidden = 'forbidden',
  generalException = 'generalException',
  invalidRequest = 'invalidRequest',
  notFound = 'notFound',
  unauthorized = 'unauthorized',
}

class ErrorResponse {
  readonly error;

  constructor(code: ErrorResponseCode, message: string, innerError?: unknown) {
    this.error = {
      code,
      message,
      innerError,
    };
  }
}

class ErrorHandler {
  public async handleError(err: Error, req: Request, res: Response) {
    req.log.error({err});

    if (isCelebrateError(err)) {
      const errors = Array.from(err.details, ([, value]) => value.message);
      const errorMessage = errors.join('\n');
      return res
        .status(StatusCodes.BAD_REQUEST)
        .json(
          new ErrorResponse(ErrorResponseCode.invalidRequest, errorMessage)
        );
    }

    if (err instanceof AlreadyExistsError) {
      return res
        .status(StatusCodes.CONFLICT)
        .json(new ErrorResponse(ErrorResponseCode.alreadyExists, err.message));
    }

    if (err instanceof ForbiddenError) {
      return res
        .status(StatusCodes.FORBIDDEN)
        .json(new ErrorResponse(ErrorResponseCode.forbidden, err.message));
    }

    if (err instanceof NotFoundError) {
      return res
        .status(StatusCodes.NOT_FOUND)
        .json(new ErrorResponse(ErrorResponseCode.notFound, err.message));
    }

    if (err instanceof RangeError) {
      return res
        .status(StatusCodes.UNPROCESSABLE_ENTITY)
        .json(new ErrorResponse(ErrorResponseCode.invalidRequest, err.message));
    }

    if (err instanceof UnauthorizedError) {
      return res
        .status(StatusCodes.UNAUTHORIZED)
        .json(
          new ErrorResponse(ErrorResponseCode.unauthorized, 'Unauthorized')
        );
    }

    return res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json(
        new ErrorResponse(
          ErrorResponseCode.generalException,
          'Internal Server Error'
        )
      );
  }
}

const errorHandler = new ErrorHandler();

export {errorHandler};
