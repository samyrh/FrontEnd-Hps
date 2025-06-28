// src/component/Footer.jsx

import {
    Box,
    Flex,
    Text,
    Link,
    Stack,
    useColorModeValue,
    Icon,
} from '@chakra-ui/react';
import { FaBuilding, FaGlobe, FaShieldAlt } from 'react-icons/fa';

export default function Footer() {
    const bg = useColorModeValue('#f4f7fe', '#18214a');
    const textColor = useColorModeValue('gray.700', 'gray.200');
    const headingColor = useColorModeValue('gray.800', 'white');
    const linkColor = useColorModeValue('#7551FF', 'blue.300');

    return (
        <Box
            bg={bg}
            width="100%"
            py="40px"
            zIndex={10}
        >
            <Flex
                px={{ base: '20px', md: '60px', lg: '100px' }}
                direction={{ base: 'column', md: 'row' }}
                justify="space-between"
                align="flex-start"
                wrap="wrap"
                gap="40px"
                maxW="100%"
            >
                {/* 🏢 Head Office */}
                <Box minW="250px">
                    <Flex align="center" gap="10px" mb="2">
                        <Icon as={FaBuilding} color={linkColor} />
                        <Text fontSize="md" fontWeight="bold" color={headingColor}>
                            Head Office
                        </Text>
                    </Flex>
                    <Text fontSize="sm" color={textColor}>HPS Headquarters</Text>
                    <Text fontSize="sm" color={textColor}>Casablanca Nearshore Park, Shore 3</Text>
                    <Text fontSize="sm" color={textColor}>Sidi Maârouf – Casablanca, Morocco</Text>
                    <Text fontSize="sm" color={textColor}>Phone: +212 5 22 97 96 00</Text>
                    <Link href="mailto:contact@hps-worldwide.com" fontSize="sm" color={linkColor}>
                        contact@hps-worldwide.com
                    </Link>
                </Box>

                {/* 🌍 Regional Contacts */}
                <Box minW="250px">
                    <Flex align="center" gap="10px" mb="2">
                        <Icon as={FaGlobe} color={linkColor} />
                        <Text fontSize="md" fontWeight="bold" color={headingColor}>
                            Regional Contacts
                        </Text>
                    </Flex>
                    <Stack spacing="1">
                        <Text fontSize="sm" color={textColor}><b>France:</b> +33 1 70 91 69 70 / france@hps-worldwide.com</Text>
                        <Text fontSize="sm" color={textColor}><b>Dubai:</b> +971 4 375 46 30 / uae@hps-worldwide.com</Text>
                        <Text fontSize="sm" color={textColor}><b>South Africa:</b> +27 11 064 5370 / sa@hps-worldwide.com</Text>
                        <Text fontSize="sm" color={textColor}><b>USA:</b> +1 646 403 4223 / usa@hps-worldwide.com</Text>
                        <Text fontSize="sm" color={textColor}><b>Asia:</b> +65 6592 5433 / asia@hps-worldwide.com</Text>
                    </Stack>
                </Box>

                {/* 🛡️ Legal */}
                <Box minW="250px">
                    <Flex align="center" gap="10px" mb="2">
                        <Icon as={FaShieldAlt} color={linkColor} />
                        <Text fontSize="md" fontWeight="bold" color={headingColor}>
                            Company & Legal
                        </Text>
                    </Flex>
                    <Stack spacing="1">
                        <Link href="https://www.hps-worldwide.com" fontSize="sm" color={linkColor} isExternal>
                            Official Website
                        </Link>
                        <Link href="/terms" fontSize="sm" color={linkColor}>Terms of Use</Link>
                        <Link href="/privacy" fontSize="sm" color={linkColor}>Privacy Policy</Link>
                        <Text fontSize="sm" color={textColor} pt="8px">
                            © {new Date().getFullYear()} HPS – Hightech Payment Systems. All rights reserved.
                        </Text>
                    </Stack>
                </Box>
            </Flex>
        </Box>
    );
}
