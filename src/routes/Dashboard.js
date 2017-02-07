import React from 'react';

import {
  Row,
  Tab,
  Col,
  Nav,
  Icon,
  Grid,
  Form,
  Table,
  Label,
  Panel,
  Button,
  NavItem,
  Checkbox,
  Progress,
  PanelBody,
  FormGroup,
  PanelLeft,
  isBrowser,
  InputGroup,
  LoremIpsum,
  PanelRight,
  PanelHeader,
  FormControl,
  PanelContainer,
  PanelTabContainer,
} from '@sketchpixy/rubix';

class Contact extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      invited: this.props.invited ? true : false,
      invitedText: this.props.invited ? 'invited' : 'invite'
    };
  }
  handleClick(e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      invited: !this.state.invited,
      invitedText: (!this.state.invited) ? 'invited': 'invite'
    });
  }
  render() {
    return (
      <tr>
        <td style={{verticalAlign: 'middle', borderTop: this.props.noBorder ? 'none': null}}>
          <img src={`/imgs/app/avatars/${this.props.avatar}.png`} />
        </td>
        <td style={{verticalAlign: 'middle', borderTop: this.props.noBorder ? 'none': null}}>
          {this.props.name}
        </td>
        <td style={{verticalAlign: 'middle', borderTop: this.props.noBorder ? 'none': null}} className='text-right'>
          <Button onlyOnHover bsStyle='orange' active={this.state.invited} onClick={::this.handleClick}>
            {this.state.invitedText}
          </Button>
        </td>
      </tr>
    );
  }
}

class MainChart extends React.Component {
  componentDidMount() {
    var chart = new Rubix('#main-chart', {
      width: '100%',
      height: 300,
      title: 'Chart of Total Users',
      titleColor: '#2EB398',
      subtitle: 'Period: 2004 and 2008',
      subtitleColor: '#2EB398',
      axis: {
        x: {
          type: 'datetime',
          tickCount: 3,
          label: 'Time',
          labelColor: '#2EB398'
        },
        y: {
          type: 'linear',
          tickFormat: 'd',
          tickCount: 2,
          labelColor: '#2EB398'
        }
      },
      tooltip: {
        color: '#55C9A6',
        format: {
          y: '.0f',
          x: '%x'
        }
      },
      margin: {
        top: 25,
        left: 50,
        right: 25
      },
      interpolate: 'linear',
      master_detail: true
    });

    var total_users = chart.area_series({
      name: 'Total Users',
      color: '#2EB398',
      marker: 'circle',
      fillopacity: 0.7,
      noshadow: true
    });

    chart.extent = [1297110663*850+(86400000*20*(.35*40)), 1297110663*850+(86400000*20*(.66*40))];

    var t = 1297110663*850;
    var v = [5, 10, 2, 20, 40, 35, 30, 20, 25, 10, 20, 10, 20, 15, 25, 20, 30, 25, 30, 25, 30, 35, 40, 20, 15, 20, 10, 25, 15, 20, 10, 25, 30, 30, 25, 20, 10, 50, 60, 30];

    var getValue = function() {
      var val = v.shift();
      v.push(val);
      return val;
    }

    var data = d3.range(40).map(function() {
      return {
        x: (t+=(86400000*20)),
        y: getValue()
      };
    });

    total_users.addData(data);
  }
  render() {
    return (
      <PanelBody style={{paddingTop: 5}}>
        <div id='main-chart'></div>
      </PanelBody>
    );
  }
}

class MaleFemaleChart extends React.Component {
  componentDidMount() {
    var chart = new Rubix('#male-female-chart', {
      height: 200,
      title: 'Demographics',
      subtitle: 'Visitors',
      axis: {
        x: {
          type: 'ordinal',
          tickFormat: 'd',
          tickCount: 2,
          label: 'Time'
        },
        y:  {
          type: 'linear',
          tickFormat: 'd'
        }
      },
      tooltip: {
        theme_style: 'dark',
        format: {
          y: '.0f'
        },
        abs: {
          y: true
        }
      },
      stacked: true,
      interpolate: 'linear',
      show_markers: true
    });

    var column = chart.column_series({
      name: 'Male Visitors',
      color: '#2D89EF',
      marker: 'cross'
    });

    var data = [
      {x: 2005, y: 21},
      {x: 2006, y: 44},
      {x: 2007, y: 14},
      {x: 2008, y: 18},
      {x: 2009, y: 23},
      {x: 2010, y: 21}
    ];
    column.addData(data);

    var column1 = chart.column_series({
      name: 'Female Visitors',
      color: '#FF0097',
      marker: 'diamond'
    });

    var data1 = [
      {x: 2005, y: -79},
      {x: 2006, y: -56},
      {x: 2007, y: -86},
      {x: 2008, y: -82},
      {x: 2009, y: -77},
      {x: 2010, y: -79}
    ];
    column1.addData(data1);
  }
  render() {
    return <div id='male-female-chart'></div>;
  }
}

class SocialSwitches extends React.Component {
  componentDidMount() {
    var elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));

    elems.forEach(function(html) {
      var switchery = new Switchery(html);
    });
  }
  render() {
    return (
      <Table className='panel-switches' collapsed>
        <tbody>
          <tr>
            <td>
              <Icon glyph='icon-fontello-twitter' className='fg-blue' /><span className='text-uppercase panel-switches-text'>twitter</span>
            </td>
            <td className='panel-switches-holder'><input type='checkbox' className='js-switch' defaultChecked /></td>
          </tr>
          <tr>
            <td>
              <Icon glyph='icon-fontello-facebook' className='fg-darkblue' /><span className='text-uppercase panel-switches-text'>facebook</span>
            </td>
            <td className='panel-switches-holder'><input type='checkbox' className='js-switch' /></td>
          </tr>
          <tr>
            <td>
              <Icon glyph='icon-fontello-gplus' className='fg-deepred' /><span className='text-uppercase panel-switches-text'>google+</span>
            </td>
            <td className='panel-switches-holder'><input type='checkbox' className='js-switch' /></td>
          </tr>
          <tr>
            <td>
              <Icon glyph='icon-fontello-linkedin' className='fg-deepred' /><span className='text-uppercase panel-switches-text'>linkedin</span>
            </td>
            <td className='panel-switches-holder'><input type='checkbox' className='js-switch' defaultChecked /></td>
          </tr>
          <tr>
            <td>
              <Icon glyph='icon-fontello-instagram' className='fg-deepred' /><span className='text-uppercase panel-switches-text'>instagram</span>
            </td>
            <td className='panel-switches-holder'>
              <Button bsStyle='primary'>connect</Button>
            </td>
          </tr>
        </tbody>
      </Table>
    );
  }
}

class NotePanel extends React.Component {
  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12} style={{padding: 50, paddingTop: 12.5, paddingBottom: 25}} className='text-center'>
            <h3 className='fg-black50'>NOTE</h3>
            <hr/>
            <p><LoremIpsum query='3s'/></p>
          </Col>
        </Row>
      </Grid>
    );
  }
}

class RevenuePanel extends React.Component {
  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12} className='text-center'>
            <br/>
            <div>
              <h4>Gross Revenue</h4>
              <h2 className='fg-green visible-xs visible-md visible-lg'>9,362.74</h2>
              <h4 className='fg-green visible-sm'>9,362.74</h4>
            </div>
            <hr className='border-green'/>
            <div>
              <h4>Net Revenue</h4>
              <h2 className='fg-green visible-xs visible-md visible-lg'>6,734.89</h2>
              <h4 className='fg-green visible-sm'>6,734.89</h4>
            </div>
          </Col>
        </Row>
      </Grid>
    );
  }
}

class LoadPanel extends React.Component {
  render() {
    return (
      <Row className='bg-green fg-lightgreen'>
        <Col xs={6}>
          <h3>Daily Load</h3>
        </Col>
        <Col xs={6} className='text-right'>
          <h2 className='fg-lightgreen'>67%</h2>
        </Col>
      </Row>
    );
  }
}

class AlertChart extends React.Component {
  componentDidMount() {
    var chart = new Rubix('#alert-chart', {
      width: '100%',
      height: 200,
      hideLegend: true,
      hideAxisAndGrid: true,
      focusLineColor: '#fff',
      theme_style: 'dark',
      axis: {
        x: {
          type: 'linear'
        },
        y: {
          type: 'linear',
          tickFormat: 'd'
        }
      },
      tooltip: {
        color: '#fff',
        format: {
          x: 'd',
          y: 'd'
        }
      },
      margin: {
        left: 25,
        top: 50,
        right: 25,
        bottom: 25
      }
    });

    var alerts = chart.column_series({
      name: 'Load',
      color: '#7CD5BA',
      nostroke: true
    });

    alerts.addData([
      {x: 0, y: 30},
      {x: 1, y: 40},
      {x: 2, y: 15},
      {x: 3, y: 30},
      {x: 4, y: 35},
      {x: 5, y: 70},
      {x: 6, y: 50},
      {x: 7, y: 60},
      {x: 8, y: 35},
      {x: 9, y: 30},
      {x: 10, y: 40},
      {x: 11, y: 30},
      {x: 12, y: 50},
      {x: 13, y: 35}
    ]);
  }
  render() {
    return (
      <Row>
        <Col xs={12}>
          <div id='alert-chart' className='rubix-chart'></div>
        </Col>
      </Row>
    );
  }
}

class RadarChartPanel extends React.Component {
  componentDidMount() {
    var data = {
      labels: ['Japan', 'France', 'USA', 'Russia', 'China', 'Dubai', 'India'],
      datasets: [{
        label: 'My First dataset',
        fillColor: 'rgba(220,220,220,0.2)',
        strokeColor: 'rgba(220,220,220,1)',
        pointColor: 'rgba(220,220,220,1)',
        pointStrokeColor: '#fff',
        pointHighlightFill: '#fff',
        pointHighlightStroke: 'rgba(220,220,220,1)',
        data: [65, 59, 90, 81, 56, 55, 40]
      }, {
        label: 'My Second dataset',
        fillColor: 'rgba(234, 120, 130, 0.5)',
        strokeColor: 'rgba(234, 120, 130, 1)',
        pointColor: 'rgba(234, 120, 130, 1)',
        pointStrokeColor: '#fff',
        pointHighlightFill: '#fff',
        pointHighlightStroke: 'rgba(151,187,205,1)',
        data: [28, 48, 40, 19, 96, 27, 100]
      }]
    };

    var ctx = document.getElementById('chartjs-1').getContext('2d');
    new Chart(ctx).Radar(data, {
      responsive: false,
      maintainAspectRatio: true
    });

    $('.line-EA7882').sparkline('html', { type: 'line', height: 25, lineColor: '#EA7882', fillColor: 'rgba(234, 120, 130, 0.5)', sparkBarColor: '#EA7882' });
    $('.line-2EB398').sparkline('html', { type: 'line', height: 25, lineColor: '#2EB398', fillColor: 'rgba(46, 179, 152, 0.5)', sparkBarColor: '#2EB398' });
    $('.line-79B0EC').sparkline('html', { type: 'line', height: 25, lineColor: '#79B0EC', fillColor: 'rgba(121, 176, 236, 0.5)', sparkBarColor: '#79B0EC' });
    $('.line-FFC497').sparkline('html', { type: 'line', height: 25, lineColor: '#FFC497', fillColor: 'rgba(255, 196, 151, 0.5)', sparkBarColor: '#FFC497' });
  }
  render() {
    return (
      <div>
        <canvas id='chartjs-1' height='250' width='250'></canvas>
        <Table striped collapsed>
          <tbody>
            <tr>
              <td className='text-left'>Bounce Rate:</td>
              <td className='text-center'>
                <Label className='bg-red fg-white'>+46%</Label>
              </td>
              <td className='text-right'>
                <div className='line-EA7882'>2,3,7,5,4,4,3,2,3,4,3,2,4,3,4,3,2,5</div>
              </td>
            </tr>
            <tr>
              <td className='text-left'>New visits:</td>
              <td className='text-center'>
                <Label className='bg-darkgreen45 fg-white'>+23%</Label>
              </td>
              <td className='text-right'>
                <div className='line-2EB398'>7,7,7,7,7,7,6,7,4,7,7,7,7,5,7,7,7,9</div>
              </td>
            </tr>
            <tr>
              <td className='text-left'>Transactions:</td>
              <td className='text-center'>
                <Label className='bg-blue fg-white'>43,000 (+50%)</Label>
              </td>
              <td className='text-right'>
                <div className='line-79B0EC'>4,6,7,7,4,3,2,1,4,9,3,2,3,5,2,4,3,1</div>
              </td>
            </tr>
            <tr>
              <td className='text-left'>Conversions:</td>
              <td className='text-center'>
                <Label className='bg-orange fg-white'>2000 (+75%)</Label>
              </td>
              <td className='text-right'>
                <div className='line-FFC497'>3,2,4,6,7,4,5,7,4,3,2,1,4,6,7,8,2,8</div>
              </td>
            </tr>
          </tbody>
        </Table>
      </div>
    );
  }
}

class ContactListPanel extends React.Component {
  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12} style={{padding: 25}}>
            <Form>
              <FormGroup>
                <InputGroup>
                  <FormControl type='text' placeholder='Type a name here...' className='border-orange border-focus-darkorange'/>
                  <InputGroup.Button>
                    <Button bsStyle='orange'>
                      <Icon glyph='icon-fontello-search'/>
                    </Button>
                  </InputGroup.Button>
                </InputGroup>
              </FormGroup>
            </Form>
            <div className='text-center'>
              <Checkbox>Invite all friends</Checkbox>
            </div>
            <div>
              <Table collapsed>
                <tbody>
                  <Contact name='Jordyn Ouellet' avatar='avatar5' noBorder />
                  <Contact name='Ava Perry' avatar='avatar9' />
                  <Contact name='Angelina Mills' avatar='avatar10' invited />
                  <Contact name='Crystal Ford' avatar='avatar11' />
                  <Contact name='Toby King' avatar='avatar7' />
                  <Contact name='Ju Lan' avatar='avatar13' invited />
                  <Contact name='Alexandra Mordin' avatar='avatar20' />
                </tbody>
              </Table>
            </div>
          </Col>
        </Row>
      </Grid>
    );
  }
}

class TicketsPanel extends React.Component {
  componentDidMount() {
    var ticketsCleared = Rubix.Donut('#tickets-cleared', {
      title: 'Tickets Cleared',
      subtitle: 'by agents',
      titleColor: '#EBA068',
      subtitleColor: '#EBA068',
      hideLegend: false,
      height: 300,
      tooltip: {
        color: '#EBA068'
      }
    });

    ticketsCleared.addData([
      {
        name: 'Karl Pohl',
        value: 57,
        color: '#FA824F'
      },
      {
        name: 'Gamze Erdoğan',
        value: 32,
        color: '#EBA068'
      },
      {
        name: 'Leyla Cəlilli',
        value: 23,
        color: '#FFC497'
      },
      {
        name: 'Nadir Üzeyirzadə',
        value: 11,
        color: '#FFC9A0'
      },
      {
        name: 'Anna Sanchez',
        value: 7,
        color: '#FFD3B1'
      }
    ]);
  }
  render() {
    return (
      <div>
        <div id='tickets-cleared'></div>
        <Table collapsed>
          <tbody>
            <tr>
              <td style={{padding: '12.5px 25px'}}>
                <Progress label='Karl Pohl' value={57} color='#FA824F' min={0} max={100} />
              </td>
              <td style={{padding: '12.5px 25px'}} className='text-right'>
                <Label>57</Label>
              </td>
            </tr>
            <tr>
              <td style={{padding: '12.5px 25px'}}>
                <Progress label='Gamze Erdoğan' value={35} color='#EBA068' min={0} max={100} />
              </td>
              <td style={{padding: '12.5px 25px'}} className='text-right'>
                <Label>33</Label>
              </td>
            </tr>
            <tr>
              <td style={{padding: '12.5px 25px'}}>
                <Progress label='Leyla Cəlilli' value={30} color='#FFC497' min={0} max={100} />
              </td>
              <td style={{padding: '12.5px 25px'}} className='text-right'>
                <Label>23</Label>
              </td>
            </tr>
            <tr>
              <td style={{padding: '12.5px 25px'}}>
                <Progress label='Nadir Üzeyirzadə' value={41} color='#FFC9A0' min={0} max={100} />
              </td>
              <td style={{padding: '12.5px 25px'}} className='text-right'>
                <Label>11</Label>
              </td>
            </tr>
            <tr>
              <td style={{padding: '12.5px 25px'}}>
                <Progress label='Anna Sanchez' value={66} color='#FFD3B1' min={0} max={100} />
              </td>
              <td style={{padding: '12.5px 25px'}} className='text-right'>
                <Label>7</Label>
              </td>
            </tr>
          </tbody>
        </Table>
      </div>
    );
  }
}

export default class Dashboard extends React.Component {
  render() {
    return (
      <div className='dashboard'>
        <Row>
          <Col sm={12}>
            <PanelTabContainer id='dashboard-main' defaultActiveKey="demographics">
              <Panel>
                <MainChart />
              </Panel>
              <Panel horizontal className='force-collapse'>
                <PanelLeft className='bg-lightgreen fg-white panel-sm-2'>
                  <RevenuePanel />
                </PanelLeft>
                <PanelRight className='bg-green fg-green panel-sm-4'>
                  <Grid>
                    <LoadPanel />
                    <AlertChart />
                  </Grid>
                </PanelRight>
              </Panel>
            </PanelTabContainer>
          </Col>
        </Row>
      </div>
    );
  }
}
