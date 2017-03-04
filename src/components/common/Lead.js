import React from 'react';
import classNames from 'classnames';

export default class Lead extends React.Component {
  render() {
    let props = {
      className: classNames('lead', this.props.className),
      ...this.props,
    };

    return <p {...props} />;
  }
}
