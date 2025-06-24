// src/component/StatCardGrid.jsx
import { Box, SimpleGrid } from '@chakra-ui/react';
import {
    FiBarChart2,
    FiShoppingCart,
    FiGrid,
    FiHome,
} from 'react-icons/fi';
import StatCard from './StatCard';

export default function StatCardGrid() {
    return (
        <Box>
            <SimpleGrid columns={{ base: 1, md: 2, lg: 3 }} spacing="24px">
                <StatCard label="Earnings" value="$340.5" icon={FiBarChart2} />
                <StatCard label="Spend this month" value="$642.39" icon={FiShoppingCart} />
                <StatCard label="Sales" value="$574.34" icon={FiBarChart2} />
                <StatCard label="Your Balance" value="$1,000" icon={FiGrid} />
                <StatCard label="New Tasks" value="145" icon={FiBarChart2} />
                <StatCard label="Total Projects" value="2433" icon={FiHome} />
            </SimpleGrid>
        </Box>
    );
}
