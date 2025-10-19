#!/usr/bin/env python3
"""
Load testing script для REST API
Генерує навантаження на сервіс для тестування автоматичного масштабування
"""

import asyncio
import aiohttp
import time
import random
import json
import argparse
import sys
from datetime import datetime
import logging

# Налаштування логування
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('load_test.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class LoadTester:
    def __init__(self, base_url, users=10, duration=60, ramp_up=10):
        self.base_url = base_url.rstrip('/')
        self.users = users
        self.duration = duration
        self.ramp_up = ramp_up
        self.session = None
        self.stats = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'response_times': [],
            'start_time': None,
            'end_time': None
        }
        
    async def create_session(self):
        """Створюємо HTTP сесію"""
        connector = aiohttp.TCPConnector(limit=100, limit_per_host=30)
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=timeout,
            auth=aiohttp.BasicAuth('user', 'password')
        )
    
    async def close_session(self):
        """Закриваємо HTTP сесію"""
        if self.session:
            await self.session.close()
    
    async def make_request(self, endpoint, method='GET', data=None):
        """Виконуємо HTTP запит"""
        url = f"{self.base_url}{endpoint}"
        start_time = time.time()
        
        try:
            if method == 'GET':
                async with self.session.get(url) as response:
                    await response.text()
            elif method == 'POST':
                async with self.session.post(url, json=data) as response:
                    await response.text()
            elif method == 'PUT':
                async with self.session.put(url, json=data) as response:
                    await response.text()
            elif method == 'DELETE':
                async with self.session.delete(url) as response:
                    await response.text()
            
            response_time = time.time() - start_time
            self.stats['response_times'].append(response_time)
            self.stats['successful_requests'] += 1
            
            return True, response_time
            
        except Exception as e:
            response_time = time.time() - start_time
            logger.error(f"Request failed: {e}")
            self.stats['failed_requests'] += 1
            return False, response_time
    
    async def user_workload(self, user_id):
        """Робоче навантаження для одного користувача"""
        logger.info(f"User {user_id} started")
        
        # Список ендпоінтів для тестування
        endpoints = [
            ('/api/authors', 'GET'),
            ('/api/books', 'GET'),
            ('/api/authors/1', 'GET'),
            ('/api/books/1', 'GET'),
        ]
        
        # Дані для POST запитів
        author_data = {
            "name": f"Test Author {user_id}",
            "birthYear": random.randint(1900, 2000)
        }
        
        book_data = {
            "title": f"Test Book {user_id}",
            "yearPublished": random.randint(1950, 2023),
            "author": {"id": 1}
        }
        
        start_time = time.time()
        end_time = start_time + self.duration
        
        while time.time() < end_time:
            # Випадковий вибір ендпоінта
            endpoint, method = random.choice(endpoints)
            
            # Іноді додаємо POST запити
            if random.random() < 0.1:  # 10% шанс на POST
                if 'authors' in endpoint:
                    await self.make_request('/api/authors', 'POST', author_data)
                elif 'books' in endpoint:
                    await self.make_request('/api/books', 'POST', book_data)
            else:
                await self.make_request(endpoint, method)
            
            self.stats['total_requests'] += 1
            
            # Випадкова затримка між запитами (0.1-2 секунди)
            await asyncio.sleep(random.uniform(0.1, 2.0))
        
        logger.info(f"User {user_id} finished")
    
    async def ramp_up_users(self):
        """Поступове додавання користувачів"""
        tasks = []
        
        for i in range(self.users):
            # Додаємо користувача з затримкою
            await asyncio.sleep(self.ramp_up / self.users)
            task = asyncio.create_task(self.user_workload(i + 1))
            tasks.append(task)
            logger.info(f"Started user {i + 1}/{self.users}")
        
        return tasks
    
    async def run_test(self):
        """Запускаємо тест навантаження"""
        logger.info(f"Starting load test: {self.users} users, {self.duration}s duration")
        logger.info(f"Target URL: {self.base_url}")
        
        await self.create_session()
        self.stats['start_time'] = datetime.now()
        
        try:
            # Поступове додавання користувачів
            tasks = await self.ramp_up_users()
            
            # Чекаємо завершення всіх задач
            await asyncio.gather(*tasks)
            
        finally:
            self.stats['end_time'] = datetime.now()
            await self.close_session()
        
        self.print_stats()
    
    def print_stats(self):
        """Виводимо статистику тесту"""
        duration = (self.stats['end_time'] - self.stats['start_time']).total_seconds()
        rps = self.stats['total_requests'] / duration if duration > 0 else 0
        
        avg_response_time = sum(self.stats['response_times']) / len(self.stats['response_times']) if self.stats['response_times'] else 0
        max_response_time = max(self.stats['response_times']) if self.stats['response_times'] else 0
        min_response_time = min(self.stats['response_times']) if self.stats['response_times'] else 0
        
        success_rate = (self.stats['successful_requests'] / self.stats['total_requests'] * 100) if self.stats['total_requests'] > 0 else 0
        
        logger.info("=" * 50)
        logger.info("LOAD TEST RESULTS")
        logger.info("=" * 50)
        logger.info(f"Duration: {duration:.2f} seconds")
        logger.info(f"Total Requests: {self.stats['total_requests']}")
        logger.info(f"Successful Requests: {self.stats['successful_requests']}")
        logger.info(f"Failed Requests: {self.stats['failed_requests']}")
        logger.info(f"Success Rate: {success_rate:.2f}%")
        logger.info(f"Requests per Second: {rps:.2f}")
        logger.info(f"Average Response Time: {avg_response_time:.3f}s")
        logger.info(f"Min Response Time: {min_response_time:.3f}s")
        logger.info(f"Max Response Time: {max_response_time:.3f}s")
        logger.info("=" * 50)

async def main():
    parser = argparse.ArgumentParser(description='Load testing script for REST API')
    parser.add_argument('--url', default='http://localhost:8080', help='Base URL of the API')
    parser.add_argument('--users', type=int, default=10, help='Number of concurrent users')
    parser.add_argument('--duration', type=int, default=60, help='Test duration in seconds')
    parser.add_argument('--ramp-up', type=int, default=10, help='Ramp-up time in seconds')
    
    args = parser.parse_args()
    
    tester = LoadTester(
        base_url=args.url,
        users=args.users,
        duration=args.duration,
        ramp_up=args.ramp_up
    )
    
    await tester.run_test()

if __name__ == '__main__':
    asyncio.run(main())
