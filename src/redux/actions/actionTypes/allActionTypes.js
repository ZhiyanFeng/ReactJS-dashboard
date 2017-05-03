import apiUserActionType from './apiUserActionType';
import apiDataActionType from './apiDataActionType';
import apiLocationActionType from './apiLocationActionType';
import apiGoogleActionType from './apiGoogleActionType';
import apiChannelActionType from './apiChannelActionType';
import apiAdminClaimActionType from './apiAdminClaimActionType';

module.exports = {
    ...apiUserActionType,
    ...apiDataActionType,
    ...apiLocationActionType,
    ...apiGoogleActionType,
    ...apiChannelActionType,
    ...apiAdminClaimActionType,
};
