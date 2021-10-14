import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import { ThemeProvider } from '@material-ui/styles';
import { createMuiTheme } from '@material-ui/core/styles';
import { Provider } from 'react-redux';

import store from './store';

const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#0052D2',
    },
    secondary: {
      main: '#91BAD6',
    },
    white: {
      main: '#FFFFFF'
    }
  },
});

ReactDOM.render(
    <ThemeProvider theme={theme}>
      <Provider store={store}>
        <App theme={theme} />
      </Provider>
    </ThemeProvider>,
  document.getElementById('root')
);

