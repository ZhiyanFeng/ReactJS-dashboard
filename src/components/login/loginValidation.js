import Validator from 'validator';
import isEmpty from 'lodash/isEmpty';

export default function validateInput(data) {
  let errors = {};

    if (!Validator.isEmail(data.email)) {
        errors.email = 'Email is invalid';
    }
    if (Validator.isEmpty(data.password)) {
        errors.password = 'This field is required';
    }
    //if (Validator.isNull(data.passwordConfirmation)) {
    //iferrors.passwordConfirmation = 'This field is required';
    //}
    //if (!Validator.equals(data.password, data.passwordConfirmation)) {
    //iferrors.passwordConfirmation = 'Passwords must match';
    //}

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
