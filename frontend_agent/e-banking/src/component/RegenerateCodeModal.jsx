// src/component/RegenerateCodeModal.jsx
import {
    Modal,
    ModalOverlay,
    ModalContent,
    ModalCloseButton,
    Box,
    Text,
    Flex,
    Spinner,
    Button,
    useColorModeValue,
} from '@chakra-ui/react';
import { useState, useEffect } from 'react';

export default function RegenerateCodeModal({ isOpen, onClose, codeType }) {
    const [isLoading, setIsLoading] = useState(true);
    const [isSent, setIsSent] = useState(false);

    // ✅ Hooks must always be at the top
    const textColor = useColorModeValue('gray.600', 'gray.300');
    const bodyBg = useColorModeValue('white', '#0B1437');
    const codeBg = useColorModeValue('gray.100', 'gray.700');

    // Simulate loading
    useEffect(() => {
        if (isOpen) {
            setIsLoading(true);
            setIsSent(false);
            const timer = setTimeout(() => {
                setIsLoading(false);
            }, 2000);
            return () => clearTimeout(timer);
        }
    }, [isOpen]);

    const handleSend = () => {
        setIsSent(true);
    };

    return (
        <Modal isOpen={isOpen} onClose={onClose} isCentered size="sm">
            <ModalOverlay />
            <ModalContent
                borderRadius="16px"
                bg={bodyBg}
                py={6}
                px={6}
                boxShadow="0 8px 30px rgba(0,0,0,0.2)"
            >
                <ModalCloseButton color={textColor} />

                <Flex direction="column" align="center">
                    {isLoading ? (
                        <>
                            <Spinner size="lg" color="blue.500" mb={4} />
                            <Text fontWeight="medium" color={textColor}>
                                Generating {codeType}...
                            </Text>
                        </>
                    ) : (
                        <>
                            <Text fontSize="sm" color={textColor} mb={2}>
                                Your new {codeType}:
                            </Text>
                            <Box
                                bg={codeBg}
                                px={4}
                                py={2}
                                rounded="md"
                                fontWeight="bold"
                                letterSpacing="0.2em"
                                mb={4}
                            >
                                ••••
                            </Box>
                            {!isSent ? (
                                <Button
                                    colorScheme="blue"
                                    onClick={handleSend}
                                    w="100%"
                                    mb={2}
                                >
                                    Send {codeType} to Cardholder
                                </Button>
                            ) : (
                                <Text fontSize="sm" color="green.400" fontWeight="medium">
                                    {codeType} sent successfully!
                                </Text>
                            )}
                        </>
                    )}
                </Flex>
            </ModalContent>
        </Modal>
    );
}
