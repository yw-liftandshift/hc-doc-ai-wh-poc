class ForbiddenError extends Error {
  constructor(message?: string) {
    super(message);
  }
}

export {ForbiddenError};
