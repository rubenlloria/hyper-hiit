/****************************************************************************
** File: SystemErrors.h
** Date: 13/3/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
#ifndef SYSTEMERRORS_H
#define SYSTEMERRORS_H

// --- DATABASE ERRORS (30-39) ---
#define ERROR_DB_INIT     30
#define ERROR_DB_SEED     31
#define ERROR_DB_DELETE   32

// --- PROTOCOL ERRORS (40-49) ---
#define ERROR_NEURAL_SYNC_FAIL 40
#define ERROR_MISSION_ABORT    41

#endif // SYSTEMERRORS_H
