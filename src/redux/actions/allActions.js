import getUsers from './apiUserActions';
import authActions from './authActions';

module.exports = {
    ...getUsers,
    ...authActions,
};
