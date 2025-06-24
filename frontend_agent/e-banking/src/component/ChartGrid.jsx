import {
    Box,
    SimpleGrid,
    useColorModeValue,
    Text,
    Flex,
    IconButton
} from '@chakra-ui/react';
import { FiBarChart2 } from 'react-icons/fi';
import LineChart from './LineAreaChart';
import ColumnChart from './ColumnChart';

export default function ChartGrid() {
    const bg = useColorModeValue('white', '#141f52'); // lighter dark background
    const textColor = useColorModeValue('#1A202C', 'white');

    const lineChartData = [
        {
            name: "Spent",
            data: [20, 40, 30, 50, 40, 60, 70],
        },
        {
            name: "Budget",
            data: [30, 50, 40, 60, 45, 35, 60],
        },
    ];

    const lineChartOptions = {
        chart: {
            type: 'area',
            toolbar: { show: false },
            zoom: { enabled: false },
            foreColor: textColor,
        },
        colors: ['#7551FF', '#32CDFF'],
        dataLabels: { enabled: false },
        stroke: { curve: 'smooth' },
        xaxis: {
            categories: ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'],
            labels: { style: { colors: textColor } },
        },
        yaxis: {
            labels: { style: { colors: textColor } },
        },
        legend: {
            position: 'bottom',
            labels: { colors: textColor },
        },
        grid: {
            borderColor: useColorModeValue('#EDF2F7', '#1A202C'),
            strokeDashArray: 4,
        },
    };

    const barChartData = [
        {
            name: 'Product A',
            data: [30, 40, 35, 50, 49, 60, 70],
        },
        {
            name: 'Product B',
            data: [20, 30, 25, 40, 39, 50, 60],
        },
        {
            name: 'Product C',
            data: [10, 20, 15, 30, 29, 40, 50],
        },
    ];

    const barChartOptions = {
        chart: {
            type: 'bar',
            stacked: true,
            toolbar: { show: false },
            foreColor: textColor,
        },
        colors: ['#32CDFF', '#7551FF', '#E0E0E0'],
        xaxis: {
            categories: ['17', '18', '19', '20', '21', '22', '23', '24', '25'],
            labels: { style: { colors: textColor } },
        },
        yaxis: {
            labels: { style: { colors: textColor } },
        },
        legend: {
            position: 'bottom',
            labels: { colors: textColor },
        },
        grid: {
            borderColor: useColorModeValue('#EDF2F7', '#1A202C'),
            strokeDashArray: 4,
        },
    };

    return (
        <SimpleGrid
            columns={{ base: 1, md: 2 }}
            spacing="24px"
            mt="20px"
            px={{ base: '30px', md: '60px', lg: '80px' }}
        >
            <Box
                bg={bg}
                p="24px"
                borderRadius="20px"
                minH="400px"
                w="100%"
                h="100%"
                boxShadow={useColorModeValue('0 4px 12px rgba(0,0,0,0.06)', 'dark-lg')}
            >


            <Flex justify="space-between" align="center" mb="12px">
                    <Text fontSize="xl" fontWeight="bold" color={textColor}>
                        Total Spent
                    </Text>
                    <IconButton icon={<FiBarChart2 />} size="sm" />
                </Flex>
                <LineChart chartData={lineChartData} chartOptions={lineChartOptions} />
            </Box>

            <Box
                bg={bg}
                p="24px"
                borderRadius="20px"
                boxShadow={useColorModeValue('md', 'lg')}
                backdropFilter="blur(6px)"
                minH="400px"
            >
                <Flex justify="space-between" align="center" mb="12px">
                    <Text fontSize="xl" fontWeight="bold" color={textColor}>
                        Weekly Revenue
                    </Text>
                    <IconButton icon={<FiBarChart2 />} size="sm" />
                </Flex>
                <ColumnChart chartData={barChartData} chartOptions={barChartOptions} />
            </Box>
        </SimpleGrid>
    );
}
