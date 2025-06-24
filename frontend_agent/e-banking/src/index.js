import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { ChakraProvider, extendTheme, ColorModeScript } from '@chakra-ui/react';
import { BrowserRouter } from 'react-router-dom'; // ✅ import it

const theme = extendTheme({
    config: {
        initialColorMode: 'dark',
        useSystemColorMode: false,
    },
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
        <BrowserRouter> {/* ✅ Wrap App in Router */}
            <ChakraProvider theme={theme}>
                <ColorModeScript initialColorMode="dark" />
                <App />
            </ChakraProvider>
        </BrowserRouter>
    </React.StrictMode>
);
