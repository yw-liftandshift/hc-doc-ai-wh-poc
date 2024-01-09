class UnauthorizedError extends Error {
  constructor(
    message?: string,
    public innerError?: Error | unknown
  ) {
    super(message);
  }
}

export {UnauthorizedError};
