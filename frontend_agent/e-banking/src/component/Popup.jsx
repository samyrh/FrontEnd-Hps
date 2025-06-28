// src/component/Popup.jsx
import {
    Box,
    Flex,
    Text,
    Icon,
    CloseButton,
    useColorModeValue,
} from '@chakra-ui/react';
import { FaRegHandPeace } from 'react-icons/fa';

export default function Popup({ onClose }) {
    const bg = useColorModeValue('#FFF5E0', '#c6744b'); // soft cream for light mode
    const border = useColorModeValue('1px solid #FFB672', '1px solid #FFB672');
    const textColor = useColorModeValue('black', 'white');
    const subTextColor = useColorModeValue('#ED8936', '#f38b23'); // ✅ orange subtext!

    return (
        <Flex
            position="fixed"
            top="20px"
            left="50%"
            transform="translateX(-50%)"
            bg={bg}
            border={border}
            borderRadius="16px"
            boxShadow="0px 10px 30px rgba(255, 183, 114, 0.2)"
            p="16px"
            zIndex="9999"
            minW="340px"
            maxW="90vw"
            align="center"
        >
            <Box
                bg="#FFEDD5"
                borderRadius="full"
                p="8px"
                display="flex"
                alignItems="center"
                justifyContent="center"
                mr="14px"
            >
                <Icon as={FaRegHandPeace} boxSize={5} color="#ED8936" />
            </Box>

            <Box flex="1">
                <Text fontWeight="bold" fontSize="sm" color={textColor}>
                    Almost done!
                </Text>
                <Text fontSize="xs" fontWeight="medium" color={subTextColor}>
                    Complete registration to finish adding the user.
                </Text>
            </Box>

            <CloseButton onClick={onClose} ml="12px" />
        </Flex>
    );
}
